using AssetManagementBase;
using Microsoft.Xna.Framework.Graphics;

namespace RacingGame
{
	partial class AMBExtensions
	{
		private static AssetLoader<Model> _modelLoader = (manager, assetName, settings, tag) =>
		{
			var loader = new GltfLoader();

			return loader.Load(manager, assetName);
		};

		public static Model LoadModel(this AssetManager assetManager, string assetName)
		{
			return assetManager.UseLoader(_modelLoader, assetName);
		}
	}
}