import SwiftUI
import Factory

public struct RemoteImageView<Content>: View where Content: View {
    private class TaskWrapper: ObservableObject {
        var task: Task<(), Never>?
    }

    private var url: URL?
    private var content: ((Image) -> any View)?
    private var placeholder: (() -> any View)?

    @StateObject private var taskWrapper = TaskWrapper()

    @Injected(\.imageLoader) private var imageLoader
    @State private var image: UIImage?

    public init(url: URL?) {
        self.url = url
    }

    public init<I, P>(
        url: URL?,
        @ViewBuilder content: @escaping (Image) -> I,
        @ViewBuilder placeholder: @escaping () -> P
    ) where Content == _ConditionalContent<I, P>, I: View, P: View {
        self.content = content
        self.placeholder = placeholder
        self.url = url
    }

    public var body: some View {
        ZStack {
            // We are not using if let image or else for the content. The content is always there, but with an empty image if the remote image is not loaded yet. It's done in this way to avoid issues with animations (the same happens with AsyncImage).
            if image == nil {
                if let placeholder {
                    AnyView(placeholder())
                }
            }

            if let content {
                AnyView(content(Image(uiImage: image ?? UIImage())))
            } else {
                Image(uiImage: image ?? UIImage())
            }
        }.onAppear(perform: load)
            .onDisappear(perform: cancel)
    }

    private func load() {
        guard let url else {
            image = UIImage()
            return
        }

        if let cachedImage = imageLoader.cachedImage(forUrl: url) {
            self.image = cachedImage
            return
        }

        taskWrapper.task = Task.detached {
            let image = await imageLoader.loadImage(fromUrl: url)
            await MainActor.run {
                self.image = image
                self.taskWrapper.task = nil
            }
        }
    }

    private func cancel() {
        taskWrapper.task?.cancel()
        taskWrapper.task = nil
    }
}
