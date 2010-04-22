  // World View Projection matrix that will transform the input vertices
  // to screen space.
  float4x4 worldViewProjection : WorldViewProjection;

  // The texture sampler is used to access the texture bitmap
  //in the fragment shader.
  sampler texSampler0;

  // input for our vertex shader
  struct VertexShaderInput {
    float4 position : POSITION;
    float2 tex : TEXCOORD0;  // Texture coordinates
  };

  // input for our pixel shader
  struct PixelShaderInput {
    float4 position : POSITION;
    float2 tex : TEXCOORD0;  // Texture coordinates
  };

  /**
   * The vertex shader  transforms input vertices to screen space.
   */
  PixelShaderInput vertexShaderFunction(VertexShaderInput input) {
    PixelShaderInput output;

    // Multiply the vertex positions by the worldViewProjection
    // matrix to transform them to screen space.
    output.position = mul(input.position, worldViewProjection);

    output.tex = input.tex;
    return output;
  }

 /**
  * Given the texture coordinates, our pixel shader grabs
  * the corresponding color from the texture.
  */
  float4 pixelShaderFunction(PixelShaderInput input): COLOR {
    return tex2D(texSampler0, input.tex * 10);
  }

  // Here we tell our effect file *which* functions are
  // our vertex and pixel shaders.

  // #o3d VertexShaderEntryPoint vertexShaderFunction
  // #o3d PixelShaderEntryPoint pixelShaderFunction
  // #o3d MatrixLoadOrder RowMajor