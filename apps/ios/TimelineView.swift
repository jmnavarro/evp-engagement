//
//  TimelineView.swift
//  Evan Dekhayser
//
//  Created by Evan Dekhayser on 7/25/14.
//  Copyright (c) 2014 Evan Dekhayser. All rights reserved.
//

import UIKit

/**
	Represents an instance in the Timeline. A Timeline is built using one or more of these TimeFrames.
*/
public struct TimeFrame{
	/**
		A description of the event.
	*/
	let text: String
	/**
		The date that the event occured.
	*/
	let date: String
	/**
		An optional image to show with the text and the date in the timeline.
	*/
	let image: UIImage?
}

/**
	The shape of a bullet that appears next to each event in the Timeline.
*/
public enum BulletType{
	/**
		Bullet shaped as a circle with no fill.
	*/
	case Circle
	/**
		Bullet shaped as a hexagon with no fill.
	*/
	case Hexagon
	/**
		Bullet shaped as a diamond with no fill.
	*/
	case Diamond
	/**
		Bullet shaped as a circle with no fill and a horizontal line connecting two vertices.
	*/
	case DiamondSlash
	/**
		Bullet shaped as a carrot facing inward toward the event.
	*/
	case Carrot
	/**
		Bullet shaped as an arrow pointing inward toward the event.
	*/
	case Arrow
}

/**
	View that shows the given events in bullet form.
*/
public class TimelineView: UIView {
	
	//MARK: Public Properties
	
	/**
		The events shown in the Timeline
	*/
	public var timeFrames: [TimeFrame]{
		didSet{
			setupContent()
		}
	}
	
	/**
		The color of the bullets and the lines connecting them.
	*/
	public var lineColor: UIColor = UIColor.lightGrayColor(){
		didSet{
			setupContent()
		}
	}
	
	/**
		Color of the larger Date title label in each event.
	*/
	public var titleLabelColor: UIColor = UIColor(red: 212/255, green: 52/255, blue: 53/255, alpha: 1){
		didSet{
			setupContent()
		}
	}
	
	/**
		Color of the smaller Text detail label in each event.
	*/
	public var detailLabelColor: UIColor = UIColor(red: 110/255, green: 110/255, blue: 110/255, alpha: 1){
		didSet{
			setupContent()
		}
	}
	
	/**
		The type of bullet shown next to each element.
	*/
	public var bulletType: BulletType = BulletType.Diamond{
		didSet{
			setupContent()
		}
	}
	
	//MARK: Private Properties
	
	private var imageViewer: JTSImageViewController?
	
	//MARK: Public Methods
	
	/**
		Note that the timeFrames cannot be set by this method. Further setup is required once this initalization occurs.
	
		May require more work to allow this to work with restoration.
	
		@param coder An unarchiver object.
	*/
	required public init(coder aDecoder: NSCoder) {
		timeFrames = []
		super.init(coder: aDecoder)
	}
	
	/**
		Initializes the timeline with all information needed for a complete setup.
	
		@param bulletType The type of bullet shown next to each element.
	
		@param timeFrames The events shown in the Timeline
	*/
	public init(bulletType: BulletType, timeFrames: [TimeFrame]){
		self.timeFrames = timeFrames
		self.bulletType = bulletType
		super.init(frame: CGRect.zeroRect)
		
		setTranslatesAutoresizingMaskIntoConstraints(false)
		
		setupContent()
	}
	
	//MARK: Private Methods
	
	private func setupContent(){
		for v in subviews{
			v.removeFromSuperview()
		}
		
		let guideView = UIView()
		guideView.setTranslatesAutoresizingMaskIntoConstraints(false)
		addSubview(guideView)
		addConstraints([
			NSLayoutConstraint(item: guideView, attribute: .Top, relatedBy: .Equal, toItem: self, attribute: .Top, multiplier: 1.0, constant: 24),
			NSLayoutConstraint(item: guideView, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: guideView, attribute: .Width, relatedBy: .Equal, toItem: self, attribute: .Width, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: guideView, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 0)
			])
		
		var i = 0
		
		var viewFromAbove = guideView
		
		for element in timeFrames{
			let v = blockForTimeFrame(element, imageTag: i)
			addSubview(v)
			addConstraints([
				NSLayoutConstraint(item: v, attribute: .Top, relatedBy: .Equal, toItem: viewFromAbove, attribute: .Bottom, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: v, attribute: .Left, relatedBy: .Equal, toItem: viewFromAbove, attribute: .Left, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: v, attribute: .Width, relatedBy: .Equal, toItem: viewFromAbove, attribute: .Width, multiplier: 1.0, constant: 0),
				])
			viewFromAbove = v
			i++
		}
		
		let extraSpace: CGFloat = 200
		
		let line = UIView()
		line.setTranslatesAutoresizingMaskIntoConstraints(false)
		line.backgroundColor = lineColor
		addSubview(line)
		sendSubviewToBack(line)
		addConstraints([
			NSLayoutConstraint(item: line, attribute: .Left, relatedBy: .Equal, toItem: self, attribute: .Left, multiplier: 1.0, constant: 16.5),
			NSLayoutConstraint(item: line, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1),
			NSLayoutConstraint(item: line, attribute: .Top, relatedBy: .Equal, toItem: viewFromAbove, attribute: .Bottom, multiplier: 1.0, constant: 0),
			NSLayoutConstraint(item: line, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: extraSpace)
			])
		addConstraint(NSLayoutConstraint(item: viewFromAbove, attribute: .Bottom, relatedBy: .Equal, toItem: self, attribute: .Bottom, multiplier: 1.0, constant: 0))
	}
	
	private func hexagonView(size: CGSize) -> UIView{
		let hex = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.width))
		hex.setTranslatesAutoresizingMaskIntoConstraints(false)
		hex.backgroundColor = UIColor.clearColor()
		let path = UIBezierPath()
		path.lineWidth = 1
		path.moveToPoint(CGPoint(x: size.width / 2, y: 0))
		path.addLineToPoint(CGPoint(x: size.width, y: size.height / 3))
		path.addLineToPoint(CGPoint(x: size.width, y: size.height * 2 / 3))
		path.addLineToPoint(CGPoint(x: size.width / 2, y: size.height))
		path.addLineToPoint(CGPoint(x: 0, y: size.height * 2 / 3))
		path.addLineToPoint(CGPoint(x: 0, y: size.height / 3))
		path.closePath()
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor.clearColor().CGColor
		shapeLayer.strokeColor = lineColor.CGColor
		shapeLayer.path = path.CGPath
		hex.layer.addSublayer(shapeLayer)
		return hex
	}
	
	private func diamondView(size: CGSize) -> UIView{
		let diamond = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.width))
		diamond.setTranslatesAutoresizingMaskIntoConstraints(false)
		diamond.backgroundColor = UIColor.clearColor()
		let path = UIBezierPath()
		path.lineWidth = 1
		path.moveToPoint(CGPoint(x: size.width / 2, y: 0))
		path.addLineToPoint(CGPoint(x: size.width, y: size.height / 2))
		path.addLineToPoint(CGPoint(x: size.width / 2, y: size.height))
		path.addLineToPoint(CGPoint(x: 0, y: size.width / 2))
		path.closePath()
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor.clearColor().CGColor
		shapeLayer.strokeColor = lineColor.CGColor
		shapeLayer.path = path.CGPath
		diamond.layer.addSublayer(shapeLayer)
		return diamond
	}
	
	private func diamondSlashView(size: CGSize) -> UIView{
		let diamondSlash = diamondView(size)
		let path = UIBezierPath()
		path.lineWidth = 1
		path.moveToPoint(CGPoint(x: 0, y: size.height/2))
		path.addLineToPoint(CGPoint(x: size.width, y: size.height / 2))
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor.clearColor().CGColor
		shapeLayer.strokeColor = lineColor.CGColor
		shapeLayer.path = path.CGPath
		diamondSlash.layer.addSublayer(shapeLayer)
		return diamondSlash
	}
	
	private func circleView(size: CGSize) -> UIView{
		let circle = UIView(frame: CGRect(x:0, y:0, width:14, height:14))
		circle.setTranslatesAutoresizingMaskIntoConstraints(false)
		circle.backgroundColor = UIColor.clearColor()
		circle.layer.borderWidth = 1
		circle.layer.borderColor = lineColor.CGColor
		circle.clipsToBounds = true
		circle.layer.cornerRadius = circle.frame.size.width / 2
		return circle
	}
	
	private func carrotView(size: CGSize) -> UIView{
		let carrot = UIView(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
		carrot.setTranslatesAutoresizingMaskIntoConstraints(false)
		carrot.backgroundColor = UIColor.clearColor()
		let path = UIBezierPath()
		path.lineWidth = 1
		path.moveToPoint(CGPoint(x: size.width/2, y: 0))
		path.addLineToPoint(CGPoint(x: size.width, y: size.height / 2))
		path.addLineToPoint(CGPoint(x: size.width / 2, y: size.height))
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor.clearColor().CGColor
		shapeLayer.strokeColor = lineColor.CGColor
		shapeLayer.path = path.CGPath
		carrot.layer.addSublayer(shapeLayer)
		return carrot
	}
	
	private func arrowView(size:CGSize) -> UIView{
		let arrow = carrotView(size)
		let path = UIBezierPath()
		path.lineWidth = 1
		path.moveToPoint(CGPoint(x: 0, y: size.height/2))
		path.addLineToPoint(CGPoint(x: size.width, y: size.height / 2))
		let shapeLayer = CAShapeLayer()
		shapeLayer.fillColor = UIColor.clearColor().CGColor
		shapeLayer.strokeColor = lineColor.CGColor
		shapeLayer.path = path.CGPath
		arrow.layer.addSublayer(shapeLayer)
		return arrow
	}
	
	private func blockForTimeFrame(element: TimeFrame, imageTag: Int) -> UIView{
		let v = UIView()
		v.setTranslatesAutoresizingMaskIntoConstraints(false)
		
		//bullet
		var bullet: UIView
		let s = CGSize(width: 14, height: 14)
		switch bulletType{
		case .Circle:
			bullet = circleView(s)
		case .Diamond:
			bullet = diamondView(s)
		case .DiamondSlash:
			bullet = diamondSlashView(s)
		case .Hexagon:
			bullet = hexagonView(s)
		case .Carrot:
			bullet = carrotView(s)
		case .Arrow:
			bullet = arrowView(s)
		}
		v.addSubview(bullet)
		v.addConstraints([
			NSLayoutConstraint(item: bullet, attribute: .Left, relatedBy: .Equal, toItem: v, attribute: .Left, multiplier: 1.0, constant: 10),
			NSLayoutConstraint(item: bullet, attribute: .Top, relatedBy: .Equal, toItem: v, attribute: .Top, multiplier: 1.0, constant: 0)
			])
		
		//image
		if let image = element.image{
			
			let backgroundViewForImage = UIImageView(image: image)
			backgroundViewForImage.setTranslatesAutoresizingMaskIntoConstraints(false)
			backgroundViewForImage.backgroundColor = UIColor.blackColor()
			backgroundViewForImage.layer.cornerRadius = 10
			backgroundViewForImage.layer.masksToBounds = true
			v.addSubview(backgroundViewForImage)
			v.addConstraints([
				NSLayoutConstraint(item: backgroundViewForImage, attribute: .Width, relatedBy: .Equal, toItem: v, attribute: .Width, multiplier: 1.0, constant: -60),
				NSLayoutConstraint(item: backgroundViewForImage, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 130),
				NSLayoutConstraint(item: backgroundViewForImage, attribute: .Left, relatedBy: .Equal, toItem: v, attribute: .Left, multiplier: 1.0, constant: 40),
				NSLayoutConstraint(item: backgroundViewForImage, attribute: .Top, relatedBy: .Equal, toItem: v, attribute: .Top, multiplier: 1.0, constant: 0)
				])
			/*
			let imageView = UIImageView(image: image)
			imageView.layer.cornerRadius = 10
			imageView.setTranslatesAutoresizingMaskIntoConstraints(false)
			imageView.contentMode = UIViewContentMode.ScaleAspectFit
			v.addSubview(imageView)
			imageView.tag = imageTag
			v.addConstraints([
				NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 130),
				NSLayoutConstraint(item: imageView, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 130),
				NSLayoutConstraint(item: imageView, attribute: .CenterX, relatedBy: .Equal, toItem: backgroundViewForImage, attribute: .CenterX, multiplier: 1.0, constant: 0),
				NSLayoutConstraint(item: imageView, attribute: .CenterY, relatedBy: .Equal, toItem: backgroundViewForImage, attribute: .CenterY, multiplier: 1.0, constant: 0)
				])
			
			let button = UIButton.buttonWithType(UIButtonType.Custom) as UIButton
			button.setTranslatesAutoresizingMaskIntoConstraints(false)
			button.backgroundColor = UIColor.clearColor()
			button.tag = imageTag
			button.addTarget(self, action: "tapImage:", forControlEvents: UIControlEvents.TouchUpInside)
			v.addSubview(button)
			v.addConstraints([
				NSLayoutConstraint(item: button, attribute: .Width, relatedBy: .Equal, toItem: v, attribute: .Width, multiplier: 1.0, constant: -60),
				NSLayoutConstraint(item: button, attribute: .Height, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 130),
				NSLayoutConstraint(item: button, attribute: .Left, relatedBy: .Equal, toItem: v, attribute: .Left, multiplier: 1.0, constant: 40),
				NSLayoutConstraint(item: button, attribute: .Top, relatedBy: .Equal, toItem: v, attribute: .Top, multiplier: 1.0, constant: 0)
				])
				*/
		}
		
		let y = element.image == nil ? 0 as CGFloat : 145.0 as CGFloat
		
		let titleLabel = UILabel()
		titleLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		titleLabel.font = UIFont(name: "HelveticaNeue", size: 20)
		titleLabel.textColor = titleLabelColor
		titleLabel.text = element.date
		titleLabel.numberOfLines = 0
		titleLabel.layer.masksToBounds = false
		v.addSubview(titleLabel)
		v.addConstraints([
			NSLayoutConstraint(item: titleLabel, attribute: .Width, relatedBy: .Equal, toItem: v, attribute: .Width, multiplier: 1.0, constant: -40),
			NSLayoutConstraint(item: titleLabel, attribute: .Left, relatedBy: .Equal, toItem: v, attribute: .Left, multiplier: 1.0, constant: 40),
			NSLayoutConstraint(item: titleLabel, attribute: .Top, relatedBy: .Equal, toItem: v, attribute: .Top, multiplier: 1.0, constant: y - 5)
			])
		
		let textLabel = UILabel()
		textLabel.setTranslatesAutoresizingMaskIntoConstraints(false)
		textLabel.font = UIFont(name: "HelveticaNeue-Thin", size: 16)
		textLabel.text = element.text
		textLabel.textColor = detailLabelColor
		textLabel.numberOfLines = 0
		textLabel.layer.masksToBounds = false
		v.addSubview(textLabel)
		v.addConstraints([
			NSLayoutConstraint(item: textLabel, attribute: .Width, relatedBy: .Equal, toItem: v, attribute: .Width, multiplier: 1.0, constant: -40),
			NSLayoutConstraint(item: textLabel, attribute: .Left, relatedBy: .Equal, toItem: v, attribute: .Left, multiplier: 1.0, constant: 40),
			NSLayoutConstraint(item: textLabel, attribute: .Top, relatedBy: .Equal, toItem: titleLabel, attribute: .Bottom, multiplier: 1.0, constant: 5),
			NSLayoutConstraint(item: textLabel, attribute: .Bottom, relatedBy: .Equal, toItem: v, attribute: .Bottom, multiplier: 1.0, constant: -10)
			])
		
		//draw the line between the bullets
		let line = UIView()
		line.setTranslatesAutoresizingMaskIntoConstraints(false)
		line.backgroundColor = lineColor
		v.addSubview(line)
		sendSubviewToBack(line)
		v.addConstraints([
			NSLayoutConstraint(item: line, attribute: .Width, relatedBy: .Equal, toItem: nil, attribute: .NotAnAttribute, multiplier: 1.0, constant: 1),
			NSLayoutConstraint(item: line, attribute: .Left, relatedBy: .Equal, toItem: v, attribute: .Left, multiplier: 1.0, constant: 16.5),
			NSLayoutConstraint(item: line, attribute: .Top, relatedBy: .Equal, toItem: v, attribute: .Top, multiplier: 1.0, constant: 14),
			NSLayoutConstraint(item: line, attribute: .Height, relatedBy: .Equal, toItem: v, attribute: .Height, multiplier: 1.0, constant: -14)
			])
		
		return v
	}
	
	private func tapImage(button: UIButton){
		var imageView: UIImageView? = nil
		for v in subviews{
			for w in v.subviews{
				if w.tag == button.tag && w is UIImageView{
					imageView = (w as UIImageView)
				}
			}
		}
		if let i = imageView{
			let imageInfo = JTSImageInfo()
			imageInfo.image = i.image
			imageInfo.referenceRect = convertRect(i.frame, fromView: i.superview)
			imageInfo.referenceView = self
			imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image, backgroundStyle: JTSImageViewControllerBackgroundStyle._ScaledDimmedBlurred)
			imageViewer!.showFromViewController(UIApplication.sharedApplication().keyWindow?.rootViewController, transition: JTSImageViewControllerTransition._FromOriginalPosition)
		}
	}
}