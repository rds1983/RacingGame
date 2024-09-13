using Microsoft.Xna.Framework.Graphics;
using System.Reflection;
using System.Linq;
using System.Collections.Generic;
using RacingGame.Graphics;
using Model = Microsoft.Xna.Framework.Graphics.Model;
using Microsoft.Xna.Framework;

namespace RacingGame.Utility
{
	internal static class XNA
	{
		public static int GetSize(this VertexElementFormat elementFormat)
		{
			switch (elementFormat)
			{
				case VertexElementFormat.Single:
					return 4;
				case VertexElementFormat.Vector2:
					return 8;
				case VertexElementFormat.Vector3:
					return 12;
				case VertexElementFormat.Vector4:
					return 16;
				case VertexElementFormat.Color:
					return 4;
				case VertexElementFormat.Byte4:
					return 4;
				case VertexElementFormat.Short2:
					return 4;
				case VertexElementFormat.Short4:
					return 8;
				case VertexElementFormat.NormalizedShort2:
					return 4;
				case VertexElementFormat.NormalizedShort4:
					return 8;
				case VertexElementFormat.HalfVector2:
					return 4;
				case VertexElementFormat.HalfVector4:
					return 8;
			}

			return 0;
		}

		private static void SetProperty<T>(this T obj, string name, object value)
		{
			var propertyInfo = typeof(T).GetProperty(name);

			propertyInfo.SetValue(obj, value);
		}

		public static ModelMesh CreateModelMesh(List<ModelMeshPart> parts)
		{
			var constructorInfo = typeof(ModelMesh).GetTypeInfo().DeclaredConstructors.First();
			return (ModelMesh)constructorInfo.Invoke(new object[] { BaseGame.Device, parts });
		}

		public static void SetName(this ModelMesh mesh, string name)
		{
#if FNA
			SetProperty(mesh, "Name", name);
#else
			mesh.Name = name;
#endif
		}

		public static void SetParentBone(this ModelMesh bone, ModelBone parent)
		{
#if FNA
			SetProperty(bone, "ParentBone", parent);
#else
			bone.ParentBone = parent;
#endif
		}

		public static void SetBoundingSphere(this ModelMesh bone, BoundingSphere sphere)
		{
#if FNA
			SetProperty(bone, "BoundingSphere", sphere);
#else
			bone.BoundingSphere = sphere;
#endif
		}

		public static ModelMeshPart CreateModelMeshPart()
		{
			var constructorInfo = typeof(ModelMeshPart).GetTypeInfo().DeclaredConstructors.First();
			return (ModelMeshPart)constructorInfo.Invoke(new object[0]);
		}

		public static void SetPrimitiveCount(this ModelMeshPart meshPart, int primitiveCount)
		{
#if FNA
			SetProperty(meshPart, "PrimitiveCount", primitiveCount);
#else
			meshPart.PrimitiveCount = primitiveCount;
#endif
		}

		public static void SetIndexBuffer(this ModelMeshPart meshPart, IndexBuffer indexBuffer)
		{
#if FNA
			SetProperty(meshPart, "IndexBuffer", indexBuffer);
#else
			meshPart.IndexBuffer = indexBuffer;
#endif
		}

		public static void SetVertexBuffer(this ModelMeshPart meshPart, VertexBuffer vertexBuffer)
		{
#if FNA
			SetProperty(meshPart, "VertexBuffer", vertexBuffer);
#else
			meshPart.VertexBuffer = vertexBuffer;
#endif
		}

		public static ModelBoneCollection CreateModelBoneCollection(IList<ModelBone> bones)
		{
			var constructorInfo = typeof(ModelBoneCollection).GetTypeInfo().DeclaredConstructors.First();
			return (ModelBoneCollection)constructorInfo.Invoke(new object[] { bones });
		}

		public static ModelBone CreateModelBone()
		{
#if FNA
			var constructorInfo = typeof(ModelBone).GetTypeInfo().DeclaredConstructors.First();
			return (ModelBone)constructorInfo.Invoke(new object[0]);
#else
			return new ModelBone();
#endif
		}

		public static void SetParent(this ModelBone bone, ModelBone parent)
		{
#if FNA
			SetProperty(bone, "Parent", parent);
#else
			bone.Parent = parent;
#endif
		}

		public static void SetName(this ModelBone bone, string name)
		{
#if FNA
			SetProperty(bone, "Name", name);
#else
			bone.Name = name;
#endif
		}

		public static void SetIndex(this ModelBone bone, int index)
		{
#if FNA
			SetProperty(bone, "Index", index);
#else
			bone.Index = index;
#endif
		}

#if FNA
		public static void AddChild(this ModelBone bone, ModelBone child)
		{
			var methodInfo = typeof(ModelBone).GetMethod("AddChild", BindingFlags.Instance | BindingFlags.NonPublic);

			methodInfo.Invoke(bone, new object[] { child });
		}

		public static void AddMesh(this ModelBone bone, ModelMesh mesh)
		{
			var methodInfo = typeof(ModelBone).GetMethod("AddMesh", BindingFlags.Instance | BindingFlags.NonPublic);

			methodInfo.Invoke(bone, new object[] { mesh });
		}
#endif

		public static Model CreateModel(List<ModelBone> bones, List<ModelMesh> meshes)
		{
#if FNA
			var constructorInfo = typeof(Model).GetTypeInfo().DeclaredConstructors.First();
			return (Model)constructorInfo.Invoke(new object[] {
				BaseGame.Device,
				bones,
				meshes
			});
#else
			return new Model(BaseGame.Device, bones, meshes);
#endif
		}

		public static void SetRoot(this Model bone, ModelBone root)
		{
#if FNA
			SetProperty(bone, "Root", root);
#else
			bone.Root = root;
#endif
		}
	}
}
