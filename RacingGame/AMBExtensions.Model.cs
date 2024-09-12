using AssetManagementBase;
using Microsoft.Xna.Framework.Graphics;
using System.Diagnostics;

namespace RacingGame
{
	partial class AMBExtensions
	{
		private static AssetLoader<Model> _modelLoader = (manager, assetName, settings, tag) =>
		{
			Debug.WriteLine("Loading model: " + assetName);

			var loader = new GltfLoader();

			return loader.Load(manager, assetName);
		};

		public static Model LoadModel(this AssetManager assetManager, string assetName)
		{
			return assetManager.UseLoader(_modelLoader, assetName);
		}
	}
}