using NursiaModel;
using Microsoft.Xna.Framework;
using System;

namespace RacingGame
{
	public class ModelInfo
	{
		public NrmModel Model { get; }
		public MaterialInfo Material { get; }

		public NrmModelBone[] Bones => Model.Bones;
		public NrmMesh[] Meshes => Model.Meshes;

		public ModelInfo(NrmModel model, MaterialInfo material)
		{
			Model = model ?? throw new ArgumentNullException(nameof(model));
			Material = material ?? throw new ArgumentNullException(nameof(material));
		}

		public void CopyAbsoluteBoneTransformsTo(Matrix[] boneTransforms) => Model.CopyAbsoluteBoneTransformsTo(boneTransforms);
	}
}
