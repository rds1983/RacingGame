using AssetManagementBase;
using Microsoft.Xna.Framework;
using RacingGame.Graphics;
using System;
using System.Collections.Generic;
using System.IO;
using System.Text.Json;

namespace RacingGame
{
	partial class AMBExtensions
	{
		private class MaterialData
		{
			public string Effect { get; set; }

			public Dictionary<string, JsonElement> Parameters { get; set; }
		}

		private static AssetLoader<Dictionary<string, EffectInfo>> _effectInfoLoader = (manager, assetName, settings, tag) =>
		{
			var result = new Dictionary<string, EffectInfo>();
			var data = manager.ReadAsString(assetName);

			var materialData = JsonSerializer.Deserialize<Dictionary<string, MaterialData>>(data);

			foreach(var pair in materialData)
			{
				var md = pair.Value;

				if (string.IsNullOrEmpty(md.Effect))
				{
					continue;
				}

				// Load effect
				var effectPath = Path.ChangeExtension(md.Effect, "efb");
				var effect = manager.LoadEffect(BaseGame.Device, effectPath).Clone();
				effect.Name = pair.Key;
				int? techniqueIndex = null;

				// Set parameters
				foreach(var pair2 in md.Parameters)
				{
					var val = pair2.Value;
					if (pair2.Key == "technique")
					{
						techniqueIndex = val.GetInt32();
						continue;
					}

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

				if (techniqueIndex == null)
				{
					throw new Exception($"Could not determine technique index for {assetName}/{pair.Key}");
				}

				var effectInfo = new EffectInfo(effect, techniqueIndex.Value);
				result[pair.Key] = effectInfo;
			}

			return result;
		};

		public static Dictionary<string, EffectInfo> LoadMaterialInfo(this AssetManager assetManager, string assetName)
		{
			return assetManager.UseLoader(_effectInfoLoader, assetName);
		}
	}
}
