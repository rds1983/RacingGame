using DigitalRiseModel;
using Microsoft.Xna.Framework;
using System;

namespace RacingGame
{
	public class ModelInfo
	{
		public DrModel Model { get; }
		public MaterialInfo Material { get; }

		public DrModelBone[] Bones => Model.Bones;
		public DrMesh[] Meshes => Model.Meshes;

		public ModelInfo(DrModel model, MaterialInfo material)
		{
			Model = model ?? throw new ArgumentNullException(nameof(model));
			Material = material ?? throw new ArgumentNullException(nameof(material));
		}

		public void CopyAbsoluteBoneTransformsTo(Matrix[] boneTransforms) => Model.CopyAbsoluteBoneTransformsTo(boneTransforms);
	}
}
