/**
 * Author......: See docs/credits.txt
 * License.....: MIT
 */

#ifdef KERNEL_STATIC
#include M2S(INCLUDE_PATH/inc_vendor.h)
#include M2S(INCLUDE_PATH/inc_types.h)
#include M2S(INCLUDE_PATH/inc_platform.cl)
#include M2S(INCLUDE_PATH/inc_common.cl)
#include M2S(INCLUDE_PATH/inc_rp.h)
#include M2S(INCLUDE_PATH/inc_rp.cl)
#include M2S(INCLUDE_PATH/inc_scalar.cl)
#include M2S(INCLUDE_PATH/inc_hash_sha256.cl)
#include M2S(INCLUDE_PATH/inc_ecc_curve25519.cl)
#endif

typedef struct
{
  sha256_ctx_t user_ctx;
  sha256_ctx_t salt_ctx;
} precomputed_inputs_t;

KERNEL_FQ void m95000_mxx (KERN_ATTR_RULES_ESALT (precomputed_inputs_t))
{
  /**
   * modifier
   */
  const u64 gid = get_global_id (0);

  if (gid >= GID_CNT) return;

  /**
   * base
   */

  COPY_PW (pws[gid]);

  /**
   * loop
   */

  ecc_params_t params;
  init_params(&params);

  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos++)
  {
    pw_t tmp = PASTE_PW;
    tmp.pw_len = apply_rules (rules_buf[il_pos].cmds, tmp.i, tmp.pw_len);

    sha256_ctx_t ctx0 = esalt_bufs[DIGESTS_OFFSET_HOST].user_ctx;

    sha256_update_swap (&ctx0, tmp.i, tmp.pw_len);
    sha256_final (&ctx0);

    sha256_ctx_t ctx = esalt_bufs[DIGESTS_OFFSET_HOST].salt_ctx;

    u32 w0[4] = { ctx0.h[0], ctx0.h[1], ctx0.h[2], ctx0.h[3] };
    u32 w1[4] = { ctx0.h[4], ctx0.h[5], ctx0.h[6], ctx0.h[7] };
    u32 w2[4] = { 0 };
    u32 w3[4] = { 0 };
    
    sha256_update_64 (&ctx, w0, w1, w2, w3, sizeof(w0) + sizeof(w1));
    sha256_final (&ctx);

    u32 x[8];
    u32 y[8];
    u32 z[8];
    
    point_mul(x, y, z, &params, ctx.h);
    generate_pub_key(x, y, z, &params);
    
    /* Take using big endian indices */
    const u32 r0 = x[7 - DGST_R0];
    const u32 r1 = x[7 - DGST_R1];
    const u32 r2 = x[7 - DGST_R2];
    const u32 r3 = x[7 - DGST_R3];

    COMPARE_M_SCALAR (r0, r1, r2, r3);
  }
}

KERNEL_FQ void m95000_sxx (KERN_ATTR_RULES_ESALT (precomputed_inputs_t))
{
  /**
   * modifier
   */

  const u64 gid = get_global_id (0);
  const u64 lid = get_local_id (0);

  if (gid >= GID_CNT) return;

  /**
   * digest
   */

  const u32 search[4] =
  {
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R0],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R1],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R2],
    digests_buf[DIGESTS_OFFSET_HOST].digest_buf[DGST_R3]
  };

  /**
   * base
   */

  COPY_PW (pws[gid]);

  /**
   * loop
   */

  ecc_params_t params;
  init_params(&params);
  
  for (u32 il_pos = 0; il_pos < IL_CNT; il_pos++)
  {
    pw_t tmp = PASTE_PW;
    tmp.pw_len = apply_rules (rules_buf[il_pos].cmds, tmp.i, tmp.pw_len);

    sha256_ctx_t ctx0 = esalt_bufs[DIGESTS_OFFSET_HOST].user_ctx;

    sha256_update_swap (&ctx0, tmp.i, tmp.pw_len);
    sha256_final (&ctx0);
    
    sha256_ctx_t ctx = esalt_bufs[DIGESTS_OFFSET_HOST].salt_ctx;

    u32 w0[4] = { ctx0.h[0], ctx0.h[1], ctx0.h[2], ctx0.h[3] };
    u32 w1[4] = { ctx0.h[4], ctx0.h[5], ctx0.h[6], ctx0.h[7] };
    u32 w2[4] = { 0 };
    u32 w3[4] = { 0 };
    
    sha256_update_64 (&ctx, w0, w1, w2, w3, sizeof(w0) + sizeof(w1));
    sha256_final (&ctx);

    u32 x[8];
    u32 y[8];
    u32 z[8];

    point_mul(x, y, z, &params, ctx.h);
    generate_pub_key(x, y, z, &params);

    /* Take using big endian indices */
    const u32 r0 = x[7 - DGST_R0];
    const u32 r1 = x[7 - DGST_R1];
    const u32 r2 = x[7 - DGST_R2];
    const u32 r3 = x[7 - DGST_R3];

    COMPARE_S_SCALAR (r0, r1, r2, r3);
  }
}