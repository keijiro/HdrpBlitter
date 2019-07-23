using UnityEngine;
using UnityEngine.Rendering;
using UnityEngine.Experimental.Rendering.HDPipeline;

namespace HdrpBlitter
{
    [ExecuteAlways]
    public sealed class CrossFadeBlit : MonoBehaviour
    {
        #region Public properties

        [SerializeField] Texture _source1 = null;
        [SerializeField] Texture _source2 = null;
        [SerializeField] Color _fillColor = new Color(0, 0, 0, 0);

        public Texture source1 {
            get { return _source1; }
            set { _source1 = value; }
        }

        public Texture source2 {
            get { return _source2; }
            set { _source2 = value; }
        }

        public Color fillColor {
            get { return _fillColor; }
            set { _fillColor = value; }
        }

        [SerializeField, Range(0, 1)] float _fadeParameter = 0.5f;

        public float fadeParameter {
            get { return _fadeParameter; }
            set { _fadeParameter = value; }
        }

        [SerializeField, HideInInspector] Shader _shader = null;

        #endregion

        #region Internal objects

        string _label;
        Material _material;

        #endregion

        #region Shader property IDs

        static readonly (
            int Source1Texture,
            int Source2Texture,
            int FadeParameter,
            int FillColor
        ) _ID = (
            Shader.PropertyToID("_Source1Texture"),
            Shader.PropertyToID("_Source2Texture"),
            Shader.PropertyToID("_FadeParameter"),
            Shader.PropertyToID("_FillColor")
        );

        #endregion

        #region MonoBehaviour implementation

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

        void OnDestroy()
        {
            CoreUtils.Destroy(_material);
        }

        #endregion

        #region Custom render callback

        void CustomRender(ScriptableRenderContext context, HDCamera camera)
        {
            if (camera == null || camera.camera == null) return;

            // Target ID
            var rt = camera.camera.targetTexture;
            var rtid = rt != null ?
                new RenderTargetIdentifier(rt) : 
                new RenderTargetIdentifier(BuiltinRenderTextureType.CameraTarget);

            // Shader objects instantiation
            if (_material == null)
            {
                _material = new Material(_shader);
                _material.hideFlags = HideFlags.DontSave;
            }

            // Shader uniforms
            _material.SetTexture(_ID.Source1Texture, _source1);
            _material.SetTexture(_ID.Source2Texture, _source2);
            _material.SetFloat(_ID.FadeParameter, _fadeParameter);
            _material.SetColor(_ID.FillColor, _fillColor);

            // Blit command
            var cmd = CommandBufferPool.Get(_label);
            CoreUtils.DrawFullScreen(cmd, _material, rtid);
            context.ExecuteCommandBuffer(cmd);
            CommandBufferPool.Release(cmd);
        }

        #endregion
    }
}
