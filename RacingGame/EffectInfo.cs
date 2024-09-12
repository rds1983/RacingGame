using Microsoft.Xna.Framework.Graphics;
using System;

namespace RacingGame
{
	public class EffectInfo
	{
		public Effect Effect { get; }
		public EffectTechnique Technique { get; }

		public EffectInfo(Effect effect, int techniqueIndex)
		{
			Effect = effect ?? throw new ArgumentNullException(nameof(effect));
			Technique = effect.Techniques[techniqueIndex];
		}
	}
}
