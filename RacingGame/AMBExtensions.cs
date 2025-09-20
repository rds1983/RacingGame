using AssetManagementBase;
using DigitalRiseModel;
using Microsoft.Xna.Framework.Graphics;
using RacingGame.Graphics;
using RacingGame.Shaders;
using RacingGame.Utilities;
using System;
using System.IO;

namespace RacingGame
{
	public static partial class AMBExtensions
	{
		public static Effect LoadEffect2(this AssetManager manager, string assetName)
		{
			var folder = Path.GetDirectoryName(assetName);
			var file = Path.GetFileName(assetName);

#if FNA
			var path = folder + "/FNA/" + file;
#else
			var path = folder + "/MonoGameDX/" + file;
#endif

			return manager.LoadEffect(BaseGame.Device, path);
		}

		public static ModelInfo LoadModelInfo(this AssetManager manager, string assetName)
		{
			// Load material
			var matName = Path.ChangeExtension(assetName, "material");
			var materialInfo = manager.LoadMaterialInfo(matName);

			// Load model
			var model = manager.LoadGltf(BaseGame.Device, assetName);

			var modelInstance = new DrModelInstance
			{
				Model = model
			};

			var result = new ModelInfo(modelInstance, materialInfo);
			foreach (var meshBone in model.MeshBones)
			{
				var mesh = meshBone.Mesh;

				// Set effects
				foreach(var submesh in mesh.Submeshes)
				{
					var effect = ShaderEffect.normalMapping.Effect;
					var material = submesh.Material;

					EffectInfo info;

					if (material != null && material.Name != null && materialInfo.Effects.TryGetValue(material.Name, out info))
					{
						effect = info.Effect;
					}

					submesh.SetEffect(effect);
				}

				// Update mesh names
				var name = meshBone.GetBoneMeshName();
				var effects = materialInfo.MeshesEffects[name];
				for (var i = 0; i < Math.Min(mesh.Submeshes.Count, effects.Length); ++i)
				{
					var effectInfo = effects[i];

					var effect = effectInfo.Effect;
					mesh.Submeshes[i].SetEffect(effect);
					effect.CurrentTechnique = effectInfo.Technique;
					name += effectInfo.TechniqueIndex;

					mesh.Name = name;
				}
			}

			return result;
		}
	}
}