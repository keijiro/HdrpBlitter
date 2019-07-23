using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace HdrpBlitter
{
    [ExecuteAlways]
    public sealed class SimpleBlit : MonoBehaviour
    {
        #region Public properties

        [SerializeField] Texture _source = null;

        public Texture source {
            get { return _source; }
            set { _source = value; }
        }

        #endregion

        #region MonoBehaviour implementation

        string _label;

        void OnEnable()
        {
            _label = "Simple Blit :: " + gameObject.name;

            var data = GetComponent<HDAdditionalCameraData>();
            if (data != null) data.customRender += CustomRender;
        }

        void OnDisable()
        {
            var data = GetComponent<HDAdditionalCameraData>();
            if (data != null) data.customRender -= CustomRender;
        }

        #endregion

        #region Custom render callback

        void CustomRender(ScriptableRenderContext context, HDCamera camera)
        {
            // Target ID
            var rt = camera.camera.targetTexture;
            var rtid = rt != null ?
                new RenderTargetIdentifier(rt) : 
                new RenderTargetIdentifier(BuiltinRenderTextureType.CameraTarget);

            // Blit command
            var cmd = CommandBufferPool.Get(_label);
            cmd.Blit(_source, rtid);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        #endregion
    }
}
