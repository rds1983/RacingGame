using AssetManagementBase;
using Microsoft.Xna.Framework;
using RacingGame.Graphics;
using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Text.Json;

namespace RacingGame
{
	partial class AMBExtensions
	{
		private class MaterialData
		{
			public string Effect { get; set; }
			public string Technique { get; set; }

			public Dictionary<string, JsonElement> Parameters { get; set; }
		}

		private class MaterialData2
		{
			public Dictionary<string, MaterialData> Materials { get; set; }
			public Dictionary<string, string[]> MeshesMaterials { get; set; }

		}

		private static AssetLoader<MaterialInfo> _effectInfoLoader = (manager, assetName, settings, tag) =>
		{
			Debug.WriteLine("Loading material: " + assetName);

			var result = new MaterialInfo();
			var data = manager.ReadAsString(assetName);

			var materialData = JsonSerializer.Deserialize<MaterialData2>(data);
			foreach(var pair in materialData.Materials)
			{
				var md = pair.Value;

				if (string.IsNullOrEmpty(md.Effect))
				{
					continue;
				}

				// Load effect
				var effectPath = Path.ChangeExtension(md.Effect, "efb");
				var effect = manager.LoadEffect2(effectPath).Clone();
				effect.Name = pair.Key;

				// Set parameters
				foreach(var pair2 in md.Parameters)
				{
					var val = pair2.Value;
					var par = effect.Parameters[pair2.Key];
					if (par == null)
					{
						continue;
					}

					switch(val.ValueKind)
					{
						case JsonValueKind.String:
							// Texture
							{
								var value = manager.LoadTexture(BaseGame.Device, pair2.Value.GetString());
								par.SetValue(value);
							}
							break;
						case JsonValueKind.Array:
							switch(val.GetArrayLength())
							{
								case 1:
									{
										var value = val[0].GetSingle();
										par.SetValue(value);
									}
									break;

								case 3:
									{
										var value = new Vector3
										(
											val[0].GetSingle(),
											val[1].GetSingle(),
											val[2].GetSingle()
										);

										par.SetValue(value);
									}
									break;

								case 4:
									{
										var value = new Vector4
										(
											val[0].GetSingle(),
											val[1].GetSingle(),
											val[2].GetSingle(),
											val[3].GetSingle()
										);

										par.SetValue(value);
									}
									break;

								default:
									break;
							}

							break;

						default:
							break;
					}
				}

				var effectInfo = new EffectInfo(effect, pair.Value.Technique);
				result.Effects[pair.Key] = effectInfo;
			}

			foreach(var pair in materialData.MeshesMaterials)
			{
				var effects = new List<EffectInfo>();
				foreach(var val in pair.Value)
				{
					effects.Add(result.Effects[val]);
				}

				result.MeshesEffects[pair.Key] = effects.ToArray();
			}

			return result;
		};

		public static MaterialInfo LoadMaterialInfo(this AssetManager assetManager, string assetName)
		{
			return assetManager.UseLoader(_effectInfoLoader, assetName);
		}
	}
}
