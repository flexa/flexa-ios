//
//  MagicCodeInputView.swift
//  FlexaCore
//
//  Created by Rodrigo Ordeix on 5/7/24.
//  Copyright © 2024 Flexa. All rights reserved.
//

import UIKit
import SwiftUI

struct MagicCodeInputView: UIViewRepresentable {
    @Binding var code: String
    @Environment(\.isEnabled) var isEnabled

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: UIViewRepresentableContext<MagicCodeInputView>) -> MagicCodeInputUIView {
        let view = MagicCodeInputUIView()
        view.delegate = context.coordinator
        view.becomeFirstResponder()
        return view
    }

    func updateUIView(_ uiView: MagicCodeInputUIView, context: UIViewRepresentableContext<MagicCodeInputView>) {
        uiView.isEnabled = isEnabled
        uiView.isUserInteractionEnabled = isEnabled
    }
}

protocol MagicCodeInputUIViewDelegate: AnyObject {
    func codeCompleted(_: MagicCodeInputUIView)
}

final class MagicCodeInputUIView: UIControl {
    private var labels: [UILabel] = []
    private var doubleTapRecognizer: UITapGestureRecognizer!
    private var longPressRecognizer: UILongPressGestureRecognizer!
    private var tapRecognizer: UITapGestureRecognizer!

    private var labelBackgroundColor: UIColor {
        isEnabled ? .white : .clear
    }

    private var labelBorderButtonColor: UIColor {
        isEnabled ? .white : .gray
    }

    weak var delegate: MagicCodeInputUIViewDelegate?

    override var isEnabled: Bool {
        didSet {
            updateLabels()
            alpha = isEnabled ? 1 : 0.2
        }
    }

    var code: String = "" {
        didSet {
            updateLabels()
            checkCompletion()
        }
    }

    required init(digitsCount: Int = 6) {
        super.init(frame: .zero)
        setup(digitsCount: digitsCount)
        updateLabels()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    private func setup(digitsCount: Int) {
        code = ""
        setupLabels(digitsCount: digitsCount)
        setupGestureRecognizers()
    }

    private func setupLabels(digitsCount: Int) {
        for _ in 0..<digitsCount {
            labels.append(createLabel())
        }

        let stackView = UIStackView(arrangedSubviews: labels)
        stackView.axis = .horizontal
        stackView.spacing = 12
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: self.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            stackView.leftAnchor.constraint(equalTo: self.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: self.rightAnchor)
        ])
    }

    private func createLabel() -> UILabel {
        let label = UILabel()
        label.backgroundColor = labelBackgroundColor
        label.text = ""
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.layer.borderColor = labelBorderButtonColor.cgColor
        label.clipsToBounds = true
        label.layer.cornerRadius = 10
        label.layer.borderWidth = 1

        return label
    }

    private func setupGestureRecognizers() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(tapHandler))
        doubleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapHandler))
        doubleTapRecognizer.numberOfTapsRequired = 2
        longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(longPressHandler))

        addGestureRecognizer(tapRecognizer)
        addGestureRecognizer(doubleTapRecognizer)
        addGestureRecognizer(longPressRecognizer)

        tapRecognizer.require(toFail: doubleTapRecognizer)
        tapRecognizer.require(toFail: longPressRecognizer)
    }

    private var nextLabel: UILabel? {
        guard code.count < labels.count else {
            return nil
        }

        return labels[code.count]
    }

    private var isComplete: Bool {
        code.count == labels.count
    }

    override func paste(_ sender: Any?) {
        // Universal links are not configured yet, we are allowing to paste them here
        if let string = UIPasteboard.general.string,
           let url = URL(string: string),
           FlexaIdentity.processUniversalLink(url: url) {
            return
        }
        code = UIPasteboard.general.string?.digits ?? ""
        UIMenuController.shared.hideMenu(from: self)
    }

    override var canBecomeFirstResponder: Bool {
        true
    }

    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(UIResponderStandardEditActions.paste)
    }

    func startTyping() {
        becomeFirstResponder()
        updateLabels()
    }

    @discardableResult
    override func resignFirstResponder() -> Bool {
        let result = super.resignFirstResponder()
        updateLabels()
        return result
    }

    private func updateLabels() {
        for (index, label) in labels.enumerated() {
            if index < code.count {
                label.text = code[index]
            } else {
                label.text = ""
            }
            label.layer.borderWidth = 1
            label.layer.borderColor = labelBorderButtonColor.cgColor
            label.backgroundColor = labelBackgroundColor
        }

        if isEnabled && isFirstResponder {
            nextLabel?.layer.borderWidth = 2
            nextLabel?.layer.borderColor = UIColor.purple.cgColor
        }
    }

    private func checkCompletion() {
        guard isComplete else {
            return
        }
        resignFirstResponder()
        hideMenu()
        delegate?.codeCompleted(self)
    }

    private func toggleMenu(shouldHideIfVisible: Bool = true) {
        becomeFirstResponder()

        let menu = UIMenuController.shared

        if !menu.isMenuVisible {
            menu.showMenu(from: self, rect: bounds)
        } else if shouldHideIfVisible {
            menu.hideMenu()
        }
    }

    private func hideMenu() {
        UIMenuController.shared.hideMenu()
    }
}

// MARK: - UIKeyInput
extension MagicCodeInputUIView: UIKeyInput {
    var hasText: Bool {
        !code.isEmpty
    }

    func insertText(_ text: String) {
        code += text.digits
    }

    func deleteBackward() {
        var newCode = code
        _ = newCode.popLast()
        code = newCode
    }
}

// MARK: - UITextInputTraits
extension MagicCodeInputUIView: UITextInputTraits {
    var keyboardType: UIKeyboardType {
        get {
            .numberPad
        }
        // swiftlint:disable:next unused_setter_value
        set {

        }
    }
}

// MARK: - Gestures
extension MagicCodeInputUIView {
    @IBAction func tapHandler(_ sender: UITapGestureRecognizer) {
        if isFirstResponder {
            toggleMenu()
        } else {
            startTyping()
        }
    }

    @IBAction func doubleTapHandler(_ sender: UITapGestureRecognizer) {
        toggleMenu()
    }

    @IBAction func longPressHandler(_ sender: UILongPressGestureRecognizer) {
        toggleMenu()
    }
}

extension MagicCodeInputView {
    class Coordinator: MagicCodeInputUIViewDelegate {
        var parent: MagicCodeInputView

        func codeCompleted(_ view: MagicCodeInputUIView) {
            self.parent.code = view.code
        }

        init(_ parent: MagicCodeInputView) {
            self.parent = parent
        }
    }
}
