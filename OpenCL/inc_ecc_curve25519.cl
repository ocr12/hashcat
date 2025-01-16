#define P7 0x7fffffff
#define P6 0xffffffff
#define P5 0xffffffff
#define P4 0xffffffff
#define P3 0xffffffff
#define P2 0xffffffff
#define P1 0xffffffff
#define P0 0xffffffed

#define X7 0x2aaaaaaa
#define X6 0xaaaaaaaa
#define X5 0xaaaaaaaa
#define X4 0xaaaaaaaa
#define X3 0xaaaaaaaa
#define X2 0xaaaaaaaa
#define X1 0xaaaaaaaa
#define X0 0xaaad245a

#define Y7 0x5f51e65e
#define Y6 0x475f794b
#define Y5 0x1fe122d3
#define Y4 0x88b72eb3
#define Y3 0x6dc2b281
#define Y2 0x92839e4d
#define Y1 0xd6163a5d
#define Y0 0x81312c14

#define C7 0x55555555
#define C6 0x55555555
#define C5 0x55555555
#define C4 0x55555555
#define C3 0x55555555
#define C2 0x55555555
#define C1 0x55555555
#define C0 0x5555db9c


#define NEGATIVE_Y7 0x20ae19a1
#define NEGATIVE_Y6 0xb8a086b4
#define NEGATIVE_Y5 0xe01edd2c
#define NEGATIVE_Y4 0x7748d14c
#define NEGATIVE_Y3 0x923d4d7e
#define NEGATIVE_Y2 0x6d7c61b2
#define NEGATIVE_Y1 0x29e9c5a2
#define NEGATIVE_Y0 0x7eced3d9

#define A7 0x2aaaaaaa
#define A6 0xaaaaaaaa
#define A5 0xaaaaaaaa
#define A4 0xaaaaaaaa
#define A3 0xaaaaaaaa
#define A2 0xaaaaaaaa
#define A1 0xaaaaaa98
#define A0 0x4914a144


typedef struct
{
  u32 x[8];
  u32 y[8];
  u32 negative_y[8];
  u32 a[8];
  u32 c[8];
} ecc_params_t;

DECLSPEC void print_num(const char* prefix, PRIVATE_AS const u32* n)
{
  printf("\n%s: ", prefix);
  for (int i = 7; i >= 0; --i)
   printf("%x ", n[i]);
  printf("\n");
}

DECLSPEC u32 sub (PRIVATE_AS u32 *r, PRIVATE_AS const u32 *a, PRIVATE_AS const u32 *b)
{
  u32 c = 0; // carry/borrow

  #if defined IS_NV && HAS_SUB == 1 && HAS_SUBC == 1
  asm volatile
  (
    "sub.cc.u32   %0,  %9, %17;"
    "subc.cc.u32  %1, %10, %18;"
    "subc.cc.u32  %2, %11, %19;"
    "subc.cc.u32  %3, %12, %20;"
    "subc.cc.u32  %4, %13, %21;"
    "subc.cc.u32  %5, %14, %22;"
    "subc.cc.u32  %6, %15, %23;"
    "subc.cc.u32  %7, %16, %24;"
    "subc.u32     %8,   0,   0;"
    : "=r"(r[0]), "=r"(r[1]), "=r"(r[2]), "=r"(r[3]), "=r"(r[4]), "=r"(r[5]), "=r"(r[6]), "=r"(r[7]),
      "=r"(c)
    :  "r"(a[0]),  "r"(a[1]),  "r"(a[2]),  "r"(a[3]),  "r"(a[4]),  "r"(a[5]),  "r"(a[6]),  "r"(a[7]),
       "r"(b[0]),  "r"(b[1]),  "r"(b[2]),  "r"(b[3]),  "r"(b[4]),  "r"(b[5]),  "r"(b[6]),  "r"(b[7])
  );
  // HIP doesnt support these so we stick to OpenCL (aka IS_AMD) - is also faster without asm
  //#elif (defined IS_AMD || defined IS_HIP) && HAS_VSUB == 1 && HAS_VSUBB == 1
  #elif 0
  __asm__ __volatile__
  (
    "V_SUB_U32   %0,  %9, %17;"
    "V_SUBB_U32  %1, %10, %18;"
    "V_SUBB_U32  %2, %11, %19;"
    "V_SUBB_U32  %3, %12, %20;"
    "V_SUBB_U32  %4, %13, %21;"
    "V_SUBB_U32  %5, %14, %22;"
    "V_SUBB_U32  %6, %15, %23;"
    "V_SUBB_U32  %7, %16, %24;"
    "V_SUBB_U32  %8,   0,   0;"
    : "=v"(r[0]), "=v"(r[1]), "=v"(r[2]), "=v"(r[3]), "=v"(r[4]), "=v"(r[5]), "=v"(r[6]), "=v"(r[7]),
      "=v"(c)
    :  "v"(a[0]),  "v"(a[1]),  "v"(a[2]),  "v"(a[3]),  "v"(a[4]),  "v"(a[5]),  "v"(a[6]),  "v"(a[7]),
       "v"(b[0]),  "v"(b[1]),  "v"(b[2]),  "v"(b[3]),  "v"(b[4]),  "v"(b[5]),  "v"(b[6]),  "v"(b[7])
  );
  #else
  for (u32 i = 0; i < 8; i++)
  {
    const u32 diff = a[i] - b[i] - c;

    if (diff != a[i]) c = (diff > a[i]);

    r[i] = diff;
  }
  #endif

  return c;
}

DECLSPEC u32 add (PRIVATE_AS u32 *r, PRIVATE_AS const u32 *a, PRIVATE_AS const u32 *b)
{
  u32 c = 0; // carry/borrow

  #if defined IS_NV && HAS_ADD == 1 && HAS_ADDC == 1
  asm volatile
  (
    "add.cc.u32   %0,  %9, %17;"
    "addc.cc.u32  %1, %10, %18;"
    "addc.cc.u32  %2, %11, %19;"
    "addc.cc.u32  %3, %12, %20;"
    "addc.cc.u32  %4, %13, %21;"
    "addc.cc.u32  %5, %14, %22;"
    "addc.cc.u32  %6, %15, %23;"
    "addc.cc.u32  %7, %16, %24;"
    "addc.u32     %8,   0,   0;"
    : "=r"(r[0]), "=r"(r[1]), "=r"(r[2]), "=r"(r[3]), "=r"(r[4]), "=r"(r[5]), "=r"(r[6]), "=r"(r[7]),
      "=r"(c)
    :  "r"(a[0]),  "r"(a[1]),  "r"(a[2]),  "r"(a[3]),  "r"(a[4]),  "r"(a[5]),  "r"(a[6]),  "r"(a[7]),
       "r"(b[0]),  "r"(b[1]),  "r"(b[2]),  "r"(b[3]),  "r"(b[4]),  "r"(b[5]),  "r"(b[6]),  "r"(b[7])
  );
  // HIP doesnt support these so we stick to OpenCL (aka IS_AMD) - is also faster without asm
  //#elif (defined IS_AMD || defined IS_HIP) && HAS_VSUB == 1 && HAS_VSUBB == 1
  #elif 0
  __asm__ __volatile__
  (
    "V_ADD_U32   %0,  %9, %17;"
    "V_ADDC_U32  %1, %10, %18;"
    "V_ADDC_U32  %2, %11, %19;"
    "V_ADDC_U32  %3, %12, %20;"
    "V_ADDC_U32  %4, %13, %21;"
    "V_ADDC_U32  %5, %14, %22;"
    "V_ADDC_U32  %6, %15, %23;"
    "V_ADDC_U32  %7, %16, %24;"
    "V_ADDC_U32  %8,   0,   0;"
    : "=v"(r[0]), "=v"(r[1]), "=v"(r[2]), "=v"(r[3]), "=v"(r[4]), "=v"(r[5]), "=v"(r[6]), "=v"(r[7]),
      "=v"(c)
    :  "v"(a[0]),  "v"(a[1]),  "v"(a[2]),  "v"(a[3]),  "v"(a[4]),  "v"(a[5]),  "v"(a[6]),  "v"(a[7]),
       "v"(b[0]),  "v"(b[1]),  "v"(b[2]),  "v"(b[3]),  "v"(b[4]),  "v"(b[5]),  "v"(b[6]),  "v"(b[7])
  );
  #else
  for (u32 i = 0; i < 8; i++)
  {
    const u32 t = a[i] + b[i] + c;

    if (t != a[i]) c = (t < a[i]);

    r[i] = t;
  }
  #endif

  return c;
}

DECLSPEC void sub_mod (PRIVATE_AS u32 *r, PRIVATE_AS const u32 *a, PRIVATE_AS const u32 *b)
{
  const u32 c = sub (r, a, b); // carry

  if (c)
  {
    u32 t[8];

    t[0] = P0;
    t[1] = P1;
    t[2] = P2;
    t[3] = P3;
    t[4] = P4;
    t[5] = P5;
    t[6] = P6;
    t[7] = P7;

    add (r, r, t);
  }
}

DECLSPEC void add_mod (PRIVATE_AS u32 *r, PRIVATE_AS const u32 *a, PRIVATE_AS const u32 *b)
{
  const u32 c = add (r, a, b); // carry

  /*
   * Modulo operation:
   */

  // note: we could have an early exit in case of c == 1 => sub ()

  u32 t[8];

  t[0] = P0;
  t[1] = P1;
  t[2] = P2;
  t[3] = P3;
  t[4] = P4;
  t[5] = P5;
  t[6] = P6;
  t[7] = P7;

  // check if modulo operation is needed

  u32 mod = 1;

  if (c == 0)
  {
    for (int i = 7; i >= 0; i--)
    {
      if (r[i] < t[i])
      {
        mod = 0;

        break; // or return ! (check if faster)
      }

      if (r[i] > t[i]) break;
    }
  }

  if (mod == 1)
  {
    sub (r, r, t);
  }
}

DECLSPEC void reduce256(PRIVATE_AS u32 *r, u64 carry)
{
  carry *= 38;
  if (r[7] & 0x80000000)
  {
    carry += 19;
  }
  r[7] &= 0x7fffffff;
  for (u32 i = 0; i < 8; i++)
  {
    carry += r[i];
    r[i] = (u32)carry;
    carry >>= 32;
  }

  /* Subtract p if the result is greater than p */
  const u32 p[] = {P0, P1, P2, P3, P4, P5, P6, P7};
  u32 t[8];
  if (sub(t, r, p) == 0)
  {
    r[0] = t[0];
    r[1] = t[1];
    r[2] = t[2];
    r[3] = t[3];
    r[4] = t[4];
    r[5] = t[5];
    r[6] = t[6];
    r[7] = t[7];
  }
}

DECLSPEC void mul_mod (PRIVATE_AS u32 *r, PRIVATE_AS const u32 *a, PRIVATE_AS const u32 *b)
{
  u32 t[16] = { 0 }; // we need up to double the space (2 * 8)

  /*
   * First start with the basic a * b multiplication:
   */

  u32 t0 = 0;
  u32 t1 = 0;
  u32 c  = 0;

  for (u32 i = 0; i < 8; i++)
  {
    for (u32 j = 0; j <= i; j++)
    {
      u64 p = ((u64) a[j]) * b[i - j];

      u64 d = ((u64) t1) << 32 | t0;

      d += p;

      t0 = (u32) d;
      t1 = d >> 32;

      c += d < p; // carry
    }

    t[i] = t0;

    t0 = t1;
    t1 = c;

    c = 0;
  }

  for (u32 i = 8; i < 15; i++)
  {
    for (u32 j = i - 7; j < 8; j++)
    {
      u64 p = ((u64) a[j]) * b[i - j];

      u64 d = ((u64) t1) << 32 | t0;

      d += p;

      t0 = (u32) d;
      t1 = d >> 32;

      c += d < p;
    }

    t[i] = t0;

    t0 = t1;
    t1 = c;

    c = 0;
  }

  t[15] = t0;

  /*
  * Do reduction for curve25519 (r = t % p):
  * https://github.com/kostko/arduino-crypto/blob/master/Curve25519.cpp
  */

  /* Multiply t[8]...t[15] by 38 and add to t[0]...t[7] */
  u64 m = 0;
  if (t[7] & 0x80000000)
  {
    m = 19;
  }
  t[7] &= 0x7fffffff;
  for (u32 i = 0, j = 8; i < 8; i++, j++)
  {
    m += (u64)38 * t[j] + t[i];

    r[i] = (u32) m;

    m >>= 32;
  }

  reduce256(r, m);
}

DECLSPEC void point_double (PRIVATE_AS u32 *x, PRIVATE_AS u32 *y, PRIVATE_AS u32 *z, PRIVATE_AS u32 const *a)
{
  u32 xx[8];
  u32 yy[8];
  u32 zz[8];
  u32 yyyy[8];
  u32 s[8];
  u32 m[8];

  mul_mod(xx, x, x);
  mul_mod(yy, y, y);
  mul_mod(yyyy, yy, yy);
  mul_mod(zz, z, z);

  /* calculate s */
  add_mod(s, x, yy);
  mul_mod(s, s, s);
  sub_mod(s, s, xx);
  sub_mod(s, s, yyyy);
  add_mod(s, s, s);

  /* calculate m */
  mul_mod(m, zz, zz);
  mul_mod(m, m, a);
  /* m - 3 * xx */
  add_mod(m, m, xx);
  add_mod(m, m, xx);
  add_mod(m, m, xx);

  /* new x */
  mul_mod(x, m, m);
  sub_mod(x, x, s);
  sub_mod(x, x, s);

  /* new z */
  add_mod(z, y, z);
  mul_mod(z, z, z);
  sub_mod(z, z, yy);
  sub_mod(z, z, zz);

  /* new y */
  sub_mod(y, s, x);
  mul_mod(y, y, m);
  /* y - 8 * yyyy */
  add_mod(yyyy, yyyy, yyyy);
  add_mod(yyyy, yyyy, yyyy);
  add_mod(yyyy, yyyy, yyyy);
  sub_mod(y, y, yyyy);
}

DECLSPEC void point_add (PRIVATE_AS u32 *x1, PRIVATE_AS u32 *y1, PRIVATE_AS u32 *z1, PRIVATE_AS u32 const *x2, PRIVATE_AS const u32 *y2) // z2 = 1
{
  if ((y1[0] | y1[1] | y1[2] | y1[3] | y1[4] | y1[5] | y1[6] | y1[7]) == 0 ||
      (z1[0] | z1[1] | z1[2] | z1[3] | z1[4] | z1[5] | z1[6] | z1[7]) == 0)
  {
    x1[0] = x2[0];
    x1[1] = x2[1];
    x1[2] = x2[2];
    x1[3] = x2[3];
    x1[4] = x2[4];
    x1[5] = x2[5];
    x1[6] = x2[6];
    x1[7] = x2[7];

    y1[0] = y2[0];
    y1[1] = y2[1];
    y1[2] = y2[2];
    y1[3] = y2[3];
    y1[4] = y2[4];
    y1[5] = y2[5];
    y1[6] = y2[6];
    y1[7] = y2[7];

    z1[0] = 1;
    z1[1] = 0;
    z1[2] = 0;
    z1[3] = 0;
    z1[4] = 0;
    z1[5] = 0;
    z1[6] = 0;
    z1[7] = 0;

    return;
  }

  u32 z1z1[8];
  u32 h[8];
  u32 hh[8];
  u32 r[8];
  u32 i[8];
  u32 j[8];
  u32 v[8];

  /* compute h and h^2 */
  mul_mod(z1z1, z1, z1);
  mul_mod(h, x2, z1z1);
  sub_mod(h, h, x1);
  mul_mod(hh, h, h);

  /* compute r */
  mul_mod(r, y2, z1z1);
  mul_mod(r, r, z1);
  sub_mod(r, r, y1);
  add_mod(r, r, r);

  /* compute i = 4 * hh */
  add_mod(i, hh, hh);
  add_mod(i, i, i);

  /* compute j */
  mul_mod(j, h, i);

  /* compute v */
  mul_mod(v, x1, i);

  /* update x1 */
  mul_mod(x1, r, r);
  sub_mod(x1, x1, j);
  sub_mod(x1, x1, v); // x1 *= 2
  sub_mod(x1, x1, v);

  /* update y1 */
  mul_mod(j, j, y1);
  sub_mod(y1, v, x1);
  mul_mod(y1, y1, r);
  sub_mod(y1, y1, j); // y1 *= 2
  sub_mod(y1, y1, j);

  /* update z1 */
  add_mod(z1, z1, h);
  mul_mod(z1, z1, z1);
  sub_mod(z1, z1, z1z1);
  sub_mod(z1, z1, hh);
}

// (inverse (a, p) * a) % p == 1 (or think of a * a^-1 = a / a = 1)

DECLSPEC void inv_mod (PRIVATE_AS u32 *a)
{
  if ((a[0] | a[1] | a[2] | a[3] | a[4] | a[5] | a[6] | a[7]) == 0) return;

  u32 t0[8];

  t0[0] = a[0];
  t0[1] = a[1];
  t0[2] = a[2];
  t0[3] = a[3];
  t0[4] = a[4];
  t0[5] = a[5];
  t0[6] = a[6];
  t0[7] = a[7];

  u32 p[8];

  p[0] = P0;
  p[1] = P1;
  p[2] = P2;
  p[3] = P3;
  p[4] = P4;
  p[5] = P5;
  p[6] = P6;
  p[7] = P7;

  u32 t1[8];

  t1[0] = P0;
  t1[1] = P1;
  t1[2] = P2;
  t1[3] = P3;
  t1[4] = P4;
  t1[5] = P5;
  t1[6] = P6;
  t1[7] = P7;

  u32 t2[8] = { 0 };

  t2[0] = 0x00000001;

  u32 t3[8] = { 0 };

  u32 b = (t0[0] != t1[0])
        | (t0[1] != t1[1])
        | (t0[2] != t1[2])
        | (t0[3] != t1[3])
        | (t0[4] != t1[4])
        | (t0[5] != t1[5])
        | (t0[6] != t1[6])
        | (t0[7] != t1[7]);

  while (b)
  {
    if ((t0[0] & 1) == 0) // even
    {
      t0[0] = t0[0] >> 1 | t0[1] << 31;
      t0[1] = t0[1] >> 1 | t0[2] << 31;
      t0[2] = t0[2] >> 1 | t0[3] << 31;
      t0[3] = t0[3] >> 1 | t0[4] << 31;
      t0[4] = t0[4] >> 1 | t0[5] << 31;
      t0[5] = t0[5] >> 1 | t0[6] << 31;
      t0[6] = t0[6] >> 1 | t0[7] << 31;
      t0[7] = t0[7] >> 1;

      u32 c = 0;

      if (t2[0] & 1) c = add (t2, t2, p);

      t2[0] = t2[0] >> 1 | t2[1] << 31;
      t2[1] = t2[1] >> 1 | t2[2] << 31;
      t2[2] = t2[2] >> 1 | t2[3] << 31;
      t2[3] = t2[3] >> 1 | t2[4] << 31;
      t2[4] = t2[4] >> 1 | t2[5] << 31;
      t2[5] = t2[5] >> 1 | t2[6] << 31;
      t2[6] = t2[6] >> 1 | t2[7] << 31;
      t2[7] = t2[7] >> 1 | c     << 31;
    }
    else if ((t1[0] & 1) == 0)
    {
      t1[0] = t1[0] >> 1 | t1[1] << 31;
      t1[1] = t1[1] >> 1 | t1[2] << 31;
      t1[2] = t1[2] >> 1 | t1[3] << 31;
      t1[3] = t1[3] >> 1 | t1[4] << 31;
      t1[4] = t1[4] >> 1 | t1[5] << 31;
      t1[5] = t1[5] >> 1 | t1[6] << 31;
      t1[6] = t1[6] >> 1 | t1[7] << 31;
      t1[7] = t1[7] >> 1;

      u32 c = 0;

      if (t3[0] & 1) c = add (t3, t3, p);

      t3[0] = t3[0] >> 1 | t3[1] << 31;
      t3[1] = t3[1] >> 1 | t3[2] << 31;
      t3[2] = t3[2] >> 1 | t3[3] << 31;
      t3[3] = t3[3] >> 1 | t3[4] << 31;
      t3[4] = t3[4] >> 1 | t3[5] << 31;
      t3[5] = t3[5] >> 1 | t3[6] << 31;
      t3[6] = t3[6] >> 1 | t3[7] << 31;
      t3[7] = t3[7] >> 1 | c     << 31;
    }
    else
    {
      u32 gt = 0;

      for (int i = 7; i >= 0; i--)
      {
        if (t0[i] > t1[i])
        {
          gt = 1;

          break;
        }

        if (t0[i] < t1[i]) break;
      }

      if (gt)
      {
        sub (t0, t0, t1);

        t0[0] = t0[0] >> 1 | t0[1] << 31;
        t0[1] = t0[1] >> 1 | t0[2] << 31;
        t0[2] = t0[2] >> 1 | t0[3] << 31;
        t0[3] = t0[3] >> 1 | t0[4] << 31;
        t0[4] = t0[4] >> 1 | t0[5] << 31;
        t0[5] = t0[5] >> 1 | t0[6] << 31;
        t0[6] = t0[6] >> 1 | t0[7] << 31;
        t0[7] = t0[7] >> 1;

        u32 lt = 0;

        for (int i = 7; i >= 0; i--)
        {
          if (t2[i] < t3[i])
          {
            lt = 1;

            break;
          }

          if (t2[i] > t3[i]) break;
        }

        if (lt) add (t2, t2, p);

        sub (t2, t2, t3);

        u32 c = 0;

        if (t2[0] & 1) c = add (t2, t2, p);

        t2[0] = t2[0] >> 1 | t2[1] << 31;
        t2[1] = t2[1] >> 1 | t2[2] << 31;
        t2[2] = t2[2] >> 1 | t2[3] << 31;
        t2[3] = t2[3] >> 1 | t2[4] << 31;
        t2[4] = t2[4] >> 1 | t2[5] << 31;
        t2[5] = t2[5] >> 1 | t2[6] << 31;
        t2[6] = t2[6] >> 1 | t2[7] << 31;
        t2[7] = t2[7] >> 1 | c     << 31;
      }
      else
      {
        sub (t1, t1, t0);

        t1[0] = t1[0] >> 1 | t1[1] << 31;
        t1[1] = t1[1] >> 1 | t1[2] << 31;
        t1[2] = t1[2] >> 1 | t1[3] << 31;
        t1[3] = t1[3] >> 1 | t1[4] << 31;
        t1[4] = t1[4] >> 1 | t1[5] << 31;
        t1[5] = t1[5] >> 1 | t1[6] << 31;
        t1[6] = t1[6] >> 1 | t1[7] << 31;
        t1[7] = t1[7] >> 1;

        u32 lt = 0;

        for (int i = 7; i >= 0; i--)
        {
          if (t3[i] < t2[i])
          {
            lt = 1;

            break;
          }

          if (t3[i] > t2[i]) break;
        }

        if (lt) add (t3, t3, p);

        sub (t3, t3, t2);

        u32 c = 0;

        if (t3[0] & 1) c = add (t3, t3, p);

        t3[0] = t3[0] >> 1 | t3[1] << 31;
        t3[1] = t3[1] >> 1 | t3[2] << 31;
        t3[2] = t3[2] >> 1 | t3[3] << 31;
        t3[3] = t3[3] >> 1 | t3[4] << 31;
        t3[4] = t3[4] >> 1 | t3[5] << 31;
        t3[5] = t3[5] >> 1 | t3[6] << 31;
        t3[6] = t3[6] >> 1 | t3[7] << 31;
        t3[7] = t3[7] >> 1 | c     << 31;
      }
    }

    // update b:

    b = (t0[0] != t1[0])
      | (t0[1] != t1[1])
      | (t0[2] != t1[2])
      | (t0[3] != t1[3])
      | (t0[4] != t1[4])
      | (t0[5] != t1[5])
      | (t0[6] != t1[6])
      | (t0[7] != t1[7]);
  }

  // set result:

  a[0] = t2[0];
  a[1] = t2[1];
  a[2] = t2[2];
  a[3] = t2[3];
  a[4] = t2[4];
  a[5] = t2[5];
  a[6] = t2[6];
  a[7] = t2[7];
}

/*
 * Convert the tweak/scalar k to w-NAF (window size is 4).
 * @param naf out: w-NAF form of the tweak/scalar, a pointer to an u32 array with a size of 17.
 * @param k in: tweak/scalar which should be converted, a pointer to an u32 array with a size of 8.
 * @return Returns the loop start index.
 */
DECLSPEC int convert_to_window_naf (PRIVATE_AS u32 *naf, PRIVATE_AS const u32 *k)
{
  int loop_start = 0;

  u32 n[8];

  n[0] = k[0];
  n[1] = k[1];
  n[2] = k[2];
  n[3] = k[3];
  n[4] = k[4];
  n[5] = k[5];
  n[6] = k[6];
  n[7] = k[7];

  for (int i = 0; i <= 256; i++)
  {
    if (n[7] & 1)
    {
      int diff = n[7] & 0x3;
      naf[i >> 4] |= diff << ((i & 0xf) << 1);
      if (diff == 3)
      {
	for (int j = 7; j >= 0; --j)
	{
	  u32 t = n[j];
	  if (t < ++n[j]) // overflow propagation
	  {
	    break;
	  }
	}
      }
      else
      {
	n[7] &= ~diff;
      }

      // update start:

      loop_start = i;
    }
    
    // n = n / 2:

    n[7] = n[7] >> 1 | n[6] << 31;
    n[6] = n[6] >> 1 | n[5] << 31;
    n[5] = n[5] >> 1 | n[4] << 31;
    n[4] = n[4] >> 1 | n[3] << 31;
    n[3] = n[3] >> 1 | n[2] << 31;
    n[2] = n[2] >> 1 | n[1] << 31;
    n[1] = n[1] >> 1 | n[0] << 31;
    n[0] = n[0] >> 1;
  }

  return loop_start;
}

/*
 * @param x out: x coordinate, a pointer to an u32 array with a size of 8.
 * @param y out: y coordinate, a pointer to an u32 array with a size of 8.
 * @param params in: additional parameters
 * @param k in: tweak/scalar which should be converted, a pointer to an u32 array with a size of 8.
 * @return Returns the x coordinate with a leading parity/sign (for odd/even y), it is named a compressed coordinate.
 */
DECLSPEC void point_mul (PRIVATE_AS u32 *x, PRIVATE_AS u32 *y, PRIVATE_AS u32 *z, PRIVATE_AS const ecc_params_t* params, PRIVATE_AS const u32 *k)
{
  u32 naf[17] = { 0 };
  int loop_start = convert_to_window_naf (naf, k);

  x[0] = 0;
  x[1] = 0;
  x[2] = 0;
  x[3] = 0;
  x[4] = 0;
  x[5] = 0;
  x[6] = 0;
  x[7] = 0;

  y[0] = 0;
  y[1] = 0;
  y[2] = 0;
  y[3] = 0;
  y[4] = 0;
  y[5] = 0;
  y[6] = 0;
  y[7] = 0;

  z[0] = 1;
  z[1] = 0;
  z[2] = 0;
  z[3] = 0;
  z[4] = 0;
  z[5] = 0;
  z[6] = 0;
  z[7] = 0;
  
  // main loop (left-to-right binary algorithm):

  for (int pos = loop_start; pos >= 0; pos--)
  {
    point_double (x, y, z, params->a);

    // add only if needed:

    const u32 multiplier = (naf[pos >> 4] >> ((pos & 0xf) << 1)) & 0x3;

    // multiplier values encoded according to this table:
    //  0 -> 0
    //  1 -> 1
    //  3 -> -1
    if (multiplier)
    {
      point_add (x, y, z, params->x, (multiplier == 1) ? params->y : params->negative_y);
    }
  }
}

DECLSPEC void init_params (PRIVATE_AS ecc_params_t* params)
{
  params->x[0] = X0;
  params->x[1] = X1;
  params->x[2] = X2;
  params->x[3] = X3;
  params->x[4] = X4;
  params->x[5] = X5;
  params->x[6] = X6;
  params->x[7] = X7;

  params->y[0] = Y0;
  params->y[1] = Y1;
  params->y[2] = Y2;
  params->y[3] = Y3;
  params->y[4] = Y4;
  params->y[5] = Y5;
  params->y[6] = Y6;
  params->y[7] = Y7;

  params->negative_y[0] = NEGATIVE_Y0;
  params->negative_y[1] = NEGATIVE_Y1;
  params->negative_y[2] = NEGATIVE_Y2;
  params->negative_y[3] = NEGATIVE_Y3;
  params->negative_y[4] = NEGATIVE_Y4;
  params->negative_y[5] = NEGATIVE_Y5;
  params->negative_y[6] = NEGATIVE_Y6;
  params->negative_y[7] = NEGATIVE_Y7;
  
  params->a[0] = A0;
  params->a[1] = A1;
  params->a[2] = A2;
  params->a[3] = A3;
  params->a[4] = A4;
  params->a[5] = A5;
  params->a[6] = A6;
  params->a[7] = A7;  

  params->c[0] = C0;
  params->c[1] = C1;
  params->c[2] = C2;
  params->c[3] = C3;
  params->c[4] = C4;
  params->c[5] = C5;
  params->c[6] = C6;
  params->c[7] = C7;  
}

DECLSPEC void generate_pub_key(PRIVATE_AS u32 *x, PRIVATE_AS u32 *y, PRIVATE_AS u32 *z, const PRIVATE_AS ecc_params_t* params)
{
  inv_mod(z);
  mul_mod(z, z, z);
  mul_mod(x, x, z);

  /* We don't use add_mod here because it is not quite precise for the final result */
  u32 carry = add(x, x, params->c);
  reduce256(x, carry);
}
