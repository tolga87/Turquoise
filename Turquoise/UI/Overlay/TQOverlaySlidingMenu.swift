import Foundation
import UIKit

public typealias TQSlidingMenuCallback = () -> Void

//typedef void(^TQSlidingMenuCallback)();

@objc public enum TQOverlaySlidingMenuPosition : Int {
  case right
  case left
}

@objc public class TQOverlaySlidingMenu : NSObject, UITableViewDataSource, UITableViewDelegate {
  var menuPosition = TQOverlaySlidingMenuPosition.right
  var scrollingView: UIView?
  var title: String?
  var texts: [String] = []
  var callbacks: [TQSlidingMenuCallback] = []

  // TODO: "callbacks" is currently borked, because the Obj-C<->Swift bridging cannot figure out the blocks in the Obj-C
  //       code correspond to the closures (TQSlidingMenuCallback) here. This will be fixed in an upcoming commit.
  public class func showSlidingMenu(position: TQOverlaySlidingMenuPosition,
                             verticalOffset: CGFloat,
                             title: String,
                             texts: [String],
                             callbacks: Array<Any>) {
    guard !texts.isEmpty && !callbacks.isEmpty && callbacks.count >= texts.count else {
      return
    }

    let menu = TQOverlaySlidingMenu()
    menu.menuPosition = position
    menu.title = title
    menu.texts = texts
    // TODO: fix
//    menu.callbacks = callbacks as! [TQSlidingMenuCallback]

    let overlay = TQOverlay.sharedInstance
    overlay.show(with: nil, animated: false)
    overlay.slidingMenu = menu
    overlay.overlayView?.manualLayout = true

    let menuWidth: CGFloat = 200
    let menuOriginX = menu.calculateOriginX(position: menu.menuPosition,
                                            width: menuWidth,
                                            hidden: true)
    let menuOriginY = verticalOffset


    let maxMenuHeight = (overlay.overlayView?.bounds ?? CGRect.zero).maxY - menuOriginY
    let menuCellHeight: CGFloat = 45.0
    var menuHeight = menuCellHeight * CGFloat(menu.texts.count)
    if menu.title != nil {
      menuHeight += menuCellHeight
    }

    var tableShouldScroll = false
    if menuHeight > maxMenuHeight {
      menuHeight = maxMenuHeight
      tableShouldScroll = true
    }

    menu.scrollingView = UIView(frame: CGRect(x: menuOriginX,
                                              y: menuOriginY,
                                              width: menuWidth,
                                              height: menuHeight))
    menu.scrollingView?.backgroundColor = .orange

    let tableView = UITableView(frame: menu.scrollingView?.bounds ?? .zero)
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SettingsSliderCell")
    tableView.backgroundColor = .black
    tableView.separatorColor = UIColor(white: 0.2, alpha: 1)
    tableView.separatorInset = .zero
    tableView.layoutMargins = .zero
    tableView.dataSource = menu
    tableView.delegate = menu
    tableView.isScrollEnabled = tableShouldScroll
    menu.scrollingView?.addSubview(tableView)

    if let scrollingView = menu.scrollingView {
      overlay.overlayView?.addSubview(scrollingView)
    }
    UIView.animate(withDuration: TQOverlay.animationDuration) {
      var newFrame = menu.scrollingView?.frame ?? .zero
      newFrame.origin.x = menu.calculateOriginX(position: menu.menuPosition,
                                                width: menuWidth,
                                                hidden: false)
      menu.scrollingView?.frame = newFrame
    }
  }

  public class func dismissSlidingMenu(completion: ((Bool) -> Void)?) {
    let overlay = TQOverlay.sharedInstance
    guard let slidingMenu = overlay.slidingMenu, let scrollingView = slidingMenu.scrollingView else {
      return
    }

    UIView.animate(withDuration: TQOverlay.animationDuration,
                   animations: {
                    var scrollingViewFrame = scrollingView.frame
                    scrollingViewFrame.origin.x =
                      slidingMenu.calculateOriginX(position: slidingMenu.menuPosition,
                                                   width: scrollingView.frame.width,
                                                   hidden: true)
                    slidingMenu.scrollingView?.frame = scrollingViewFrame
    }) { (finished: Bool) in
      slidingMenu.texts = []
      slidingMenu.callbacks = []
      slidingMenu.scrollingView?.removeFromSuperview()
      overlay.slidingMenu = nil
      overlay.dismiss(animated: false)
      if let completion = completion {
        completion(finished)
      }
    }

  }

  private func calculateOriginX(position: TQOverlaySlidingMenuPosition,
                                width: CGFloat,
                                hidden: Bool) -> CGFloat {
    guard let overlayView = TQOverlay.sharedInstance.overlayView else {
      return 0
    }

    let overlayBounds = overlayView.bounds
    switch position {
    case .right:
      return hidden ? overlayBounds.maxX : overlayBounds.maxX - width

    case .left:
      return hidden ? overlayBounds.minX - width : overlayBounds.minX
    }
  }

  private func groupIndexFor(indexPath: IndexPath) -> Int {
    if self.title != nil {
      return indexPath.row - 1
    } else {
      return indexPath.row
    }
  }

  // MARK: - UITableViewDataSource

  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    var numRows = self.texts.count
    if self.title != nil {
      numRows += 1
    }
    return numRows
  }

  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsSliderCell", for: indexPath)
    cell.textLabel?.numberOfLines = 2
    cell.textLabel?.backgroundColor = .clear
    cell.textLabel?.textColor = .white
    cell.textLabel?.font = UIFont(name: "dungeon", size: 12.0)

    let isTitleCell = (self.title != nil) && (indexPath == IndexPath(row: 0, section: 0))
    if isTitleCell {
      cell.textLabel?.font = UIFont(name: "dungeon", size: 13.0)
      cell.textLabel?.text = self.title
      cell.contentView.backgroundColor = .black
      cell.isUserInteractionEnabled = false
    } else {
      let textIndex = self.groupIndexFor(indexPath: indexPath)
      cell.textLabel?.text = self.texts[textIndex]
      cell.contentView.backgroundColor = (textIndex % 2 == 0)
        ? UIColor(displayP3Red: 0, green: 0, blue: 0.5, alpha: 1)
        : UIColor(displayP3Red: 0, green: 0, blue: 1.0, alpha: 1)
      cell.isUserInteractionEnabled = true
    }
    return cell
  }

  // MARK: - UITableViewDelegate

  public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: false)
    let groupIndex = self.groupIndexFor(indexPath: indexPath)
    // TODO: fix
//    let callback = self.callbacks[groupIndex]
//    TQOverlaySlidingMenu.dismissSlidingMenu { (finished: Bool) in
//      callback()
//    }
  }

}
