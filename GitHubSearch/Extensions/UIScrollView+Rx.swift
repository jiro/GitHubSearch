import UIKit
import RxSwift
import RxCocoa

extension Reactive where Base: UIScrollView {
    func reachedToBottom(offset: CGFloat = 0) -> ControlEvent<Void> {
        let source = contentOffset
            .filter { [weak base] contentOffset in
                guard let scrollView = base, scrollView.contentSize.height > offset else { return false }
                return contentOffset.y + scrollView.frame.height >= scrollView.contentSize.height - offset
            }
            .map { _ in }
        return ControlEvent(events: source)
    }
}
