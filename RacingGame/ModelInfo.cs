using DigitalRiseModel;
using Microsoft.Xna.Framework;
using RacingGame.Graphics;
using RacingGame.Utilities;
using System;

namespace RacingGame
{
	public class ModelInfo
	{
		public DrModelInstance ModelInstance { get; }
		public MaterialInfo Material { get; }

		public DrModelBone[] Bones => ModelInstance.Model.Bones;
		public DrModelBone[] MeshBones => ModelInstance.Model.MeshBones;

		public ModelInfo(DrModelInstance modelInstance, MaterialInfo material)
		{
			ModelInstance = modelInstance ?? throw new ArgumentNullException(nameof(modelInstance));
			Material = material ?? throw new ArgumentNullException(nameof(material));
		}

		public void CopyAbsoluteBoneTransformsTo(Matrix[] transforms)
		{
			for (var i = 0; i < Bones.Length; i++)
			{
				var bone = Bones[i];
				transforms[bone.Index] = ModelInstance.GetBoneGlobalTransform(bone.Index);
			}
		}

		public void Draw(DrMesh mesh)
		{
			var graphicsDevice = BaseGame.Device;

			for (int i = 0; i < mesh.Submeshes.Count; i++)
			{
				var submesh = mesh.Submeshes[i];
				if (submesh.PrimitiveCount > 0)
				{
					var effect = submesh.GetEffect();
					for (int j = 0; j < effect.CurrentTechnique.Passes.Count; j++)
					{
						effect.CurrentTechnique.Passes[j].Apply();

						submesh.Draw(graphicsDevice);
					}
				}
			}
		}
	}
}
