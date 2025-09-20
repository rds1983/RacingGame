using DigitalRiseModel;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Graphics;
using RacingGame.Graphics;
using System;
using System.Collections.Generic;

namespace RacingGame.Utilities
{
	internal static class ModelUtils
	{
		public static float Radius(this BoundingBox b)
		{
			var m = (float)Math.Max(b.Max.X - b.Min.X, Math.Min(b.Max.Y - b.Min.Y, b.Max.Z - b.Min.Z));

			return m / 2;
		}

		public static Effect GetEffect(this DrSubmesh submesh) => (Effect)submesh.UserData;

		public static void SetEffect(this DrSubmesh submesh, Effect effect) => submesh.UserData = effect;

		public static Effect[] GetEffects(this DrMesh mesh)
		{
			if (mesh.UserData != null)
			{
				return (Effect[])mesh.UserData;
			}

			var result = new List<Effect>();

			foreach (var submesh in mesh.Submeshes)
			{
				var effect = submesh.GetEffect();
				if (effect == null)
				{
					continue;
				}

				if (!result.Contains(effect))
				{
					result.Add(effect);
				}
			}

			mesh.UserData = result.ToArray();
			return (Effect[])mesh.UserData;
		}

		public static string GetBoneMeshName(this DrModelBone bone)
		{
			if (bone.Mesh == null)
			{
				return bone.Name;
			}

			if (bone.Mesh.Name != null)
			{
				return bone.Mesh.Name;
			}

			return bone.Name;
		}

		public static void Draw(this DrMesh mesh)
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
