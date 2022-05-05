Shader "Custom/fire"
{
    Properties
    {
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _MainTex2("Albedo (RGB)", 2D) = "black" {}
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "Queue"="Transparent"}
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard alpha:fade

        sampler2D _MainTex;
        sampler2D _MainTex2;

        struct Input
        {
            float2 uv_MainTex;
            float2 uv_MainTex2;
        };

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            fixed4 d = tex2D(_MainTex2, float2(IN.uv_MainTex2.x, IN.uv_MainTex2.y - _Time.y)); // 노이즈 텍스쳐인 d를 y축 방향으로 위로 흐르도록 시간 내장변수 _Time값을 빼줌!
            fixed4 c = tex2D (_MainTex, IN.uv_MainTex + d.r * 0.5); // 더해주는 d.r 값을 줄이는 방식 (노이즈 텍스쳐를 전반적으로 더 어둡게 하거나, 내가 한 거처럼 0.x.. 를 곱해주거나)으로 전반적으로 좌하단으로 쳐진 텍스쳐를 우상단으로 살짝 끌어올리고, 구김의 정도를 약화시킬 수 있음!
            o.Albedo = c.rgb;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}

// c에 넣어줄 uv 좌표값에 d.r 을 더해준다는 게 무슨 의미일까?
// 즉, 두 번째 텍스처인 검정색 텍스쳐의 r값을 c(불 텍스쳐)의 uv 좌표값에 각각 더해준다는 것임.
// 근데, 검정색 텍스쳐는 픽셀이 전부 (0, 0, 0)이니까 결국 불텍스쳐 uv에 0을 더해준거나 마찬가지네?
// 만약 저기에 0.5나 1을 더해준다면, 텍스쳐의 모든 텍셀이 일관되게 0.5만큼 또는 1만큼 좌하단으로 이동하는 모양일거임.
// 
// 근데 만약, 저게 단순한 검정색 텍스쳐가 아니라, dot.tgb 나, noise2.png 처럼
// 각 픽셀 부분마다 밝기값이 다른 경우라면? 각 픽셀마다 d.r값도 다르겠지? 흑백은 r,g,b 가 모두 같은 값으로 움직일테니까!
// 그렇다면 각 uv 좌표에 더해주는 d.r 값도 모두 제각각이겠지?
//
// 그렇게 된다면, 텍스처의 모든 텍셀이 일관된 값만큼 이동하는 게 아니라, 픽셀 부분의 밝기값만큼 제각각 움직일거라는 뜻!
// 이로 인해, 마치 텍스처가 구겨지고 일그러지는 효과를 낼 수 있음 -> 이런 걸 위해서 필요한 게 노이즈 텍스쳐, 또는 노이즈 이미지임! (noise2.png 같은거)
//
// 위와 같은 방법으로 연기, 물 등의 효과에도 충분히 사용할 수 있는 유용한 기법임.
// 
// 그러나, 현재 셰이더는 surface surf Standard 즉, 엄청나게 무거운 물리 기반 라이팅으로 작동되고 있기 때문에
// 실무에서 사용하기에는 너무 무겁고 비효율적인 코드. 반면 우리가 만든 불 이펙트 셰이더는 물리 기반 라이팅을 전혀 사용하지 않기 때문에,
// 실무에서 이거를 사용하려면 라이팅 연산이 제거된 코드로 수정해줘야 함. -> 이거는 나중에 라이팅 연산 부분을 배우게 될 것!