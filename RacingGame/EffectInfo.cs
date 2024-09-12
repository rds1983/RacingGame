using Microsoft.Xna.Framework.Graphics;
using System;
using System.Collections.Generic;

namespace RacingGame
{
	public class EffectInfo
	{
		public Effect Effect { get; }
		public EffectTechnique Technique { get; }

		public EffectInfo(Effect effect, string techniqueName)
		{
			Effect = effect ?? throw new ArgumentNullException(nameof(effect));
			Technique = effect.Techniques[techniqueName];
		}
	}

	public class MaterialInfo
	{
		public Dictionary<string, EffectInfo> Effects { get; } = new Dictionary<string, EffectInfo>();
		public Dictionary<string, EffectInfo[]> MeshesEffects { get; } = new Dictionary<string, EffectInfo[]>();
	}
}
