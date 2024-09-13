using AssetManagementBase;
using Microsoft.Xna.Framework.Graphics;
using RacingGame.Graphics;
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
	}
}