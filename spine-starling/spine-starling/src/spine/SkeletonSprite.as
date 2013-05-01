package spine {
import flash.geom.Matrix;
import flash.geom.Point;
import flash.geom.Rectangle;

import spine.attachments.RegionAttachment;

import starling.animation.IAnimatable;
import starling.core.RenderSupport;
import starling.display.DisplayObject;
import starling.utils.MatrixUtil;

public class SkeletonSprite extends DisplayObject implements IAnimatable {
	static private var tempPoint:Point = new Point();
	static private var tempMatrix:Matrix = new Matrix();

	private var _skeleton:Skeleton;

	public function SkeletonSprite (skeletonData:SkeletonData) {
		_skeleton = new Skeleton(skeletonData);
		_skeleton.updateWorldTransform();

		Bone.yDown = true;
	}

	public function advanceTime (time:Number) : void {
		_skeleton.update(time);
	}

	override public function render (support:RenderSupport, alpha:Number) : void {
		var drawOrder:Vector.<Slot> = skeleton.drawOrder;
		for (var i:int = 0, n:int = drawOrder.length; i < n; i++) {
			var slot:Slot = drawOrder[i];
			var regionAttachment:RegionAttachment = slot.attachment as RegionAttachment;
			if (regionAttachment != null) {
				regionAttachment.updateVertices(slot.bone);
				var vertices:Vector.<Number> = regionAttachment.vertices;
				var r:Number = skeleton.r * slot.r;
				var g:Number = skeleton.g * slot.g;
				var b:Number = skeleton.b * slot.b;
				var a:Number = skeleton.a * slot.a;

				var image:SkeletonImage = regionAttachment.texture as SkeletonImage;
				var vertexData:Vector.<Number> = image.vertexData.rawData;

				vertexData[0] = vertices[2];
				vertexData[1] = vertices[3];
				vertexData[2] = r;
				vertexData[3] = g;
				vertexData[4] = b;
				vertexData[5] = a;

				vertexData[8] = vertices[4];
				vertexData[9] = vertices[5];
				vertexData[10] = r;
				vertexData[11] = g;
				vertexData[12] = b;
				vertexData[13] = a;

				vertexData[16] = vertices[0];
				vertexData[17] = vertices[1];
				vertexData[18] = r;
				vertexData[19] = g;
				vertexData[20] = b;
				vertexData[21] = a;

				vertexData[24] = vertices[6];
				vertexData[25] = vertices[7];
				vertexData[26] = r;
				vertexData[27] = g;
				vertexData[28] = b;
				vertexData[29] = a;

				image.updateVertices();
				support.batchQuad(image, alpha, image.texture);
			}
		}
	}

	override public function hitTest (localPoint:Point, forTouch:Boolean = false) : DisplayObject {
		if (forTouch && (!visible || !touchable))
			return null;

		var minX:Number = Number.MAX_VALUE, minY:Number = Number.MAX_VALUE;
		var maxX:Number = Number.MIN_VALUE, maxY:Number = Number.MIN_VALUE;
		var slots:Vector.<Slot> = skeleton.slots;
		var value:Number;
		for (var i:int = 0, n:int = slots.length; i < n; i++) {
			var slot:Slot = slots[i];
			var regionAttachment:RegionAttachment = slot.attachment as RegionAttachment;
			if (!regionAttachment)
				continue;

			regionAttachment.updateVertices(slot.bone);
			var vertices:Vector.<Number> = regionAttachment.vertices;

			value = vertices[0];
			if (value < minX)
				minX = value;
			if (value > maxX)
				maxX = value;

			value = vertices[1];
			if (value < minY)
				minY = value;
			if (value > maxY)
				maxY = value;

			value = vertices[2];
			if (value < minX)
				minX = value;
			if (value > maxX)
				maxX = value;

			value = vertices[3];
			if (value < minY)
				minY = value;
			if (value > maxY)
				maxY = value;

			value = vertices[4];
			if (value < minX)
				minX = value;
			if (value > maxX)
				maxX = value;

			value = vertices[5];
			if (value < minY)
				minY = value;
			if (value > maxY)
				maxY = value;

			value = vertices[6];
			if (value < minX)
				minX = value;
			if (value > maxX)
				maxX = value;

			value = vertices[7];
			if (value < minY)
				minY = value;
			if (value > maxY)
				maxY = value;
		}

		minX *= scaleX;
		maxX *= scaleX;
		minY *= scaleY;
		maxY *= scaleY;
		var temp:Number;
		if (maxX < minX) {
			temp = maxX;
			maxX = minX;
			minX = temp;
		}
		if (maxY < minY) {
			temp = maxY;
			maxY = minY;
			minY = temp;
		}

		if (localPoint.x >= minX && localPoint.x < maxX && localPoint.y >= minY && localPoint.y < maxY)
			return this;

		return null;
	}

	override public function getBounds (targetSpace:DisplayObject, resultRect:Rectangle = null) : Rectangle {
		if (!resultRect)
			resultRect = new Rectangle();
		if (targetSpace == this)
			resultRect.setTo(0, 0, 0, 0);
		else if (targetSpace == parent)
			resultRect.setTo(x, y, 0, 0);
		else {
			getTransformationMatrix(targetSpace, tempMatrix);
			MatrixUtil.transformCoords(tempMatrix, 0, 0, tempPoint);
			resultRect.setTo(tempPoint.x, tempPoint.y, 0, 0);
		}
		return resultRect;
	}

	public function get skeleton () : Skeleton {
		return _skeleton;
	}
}

}

