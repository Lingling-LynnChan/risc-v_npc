#include <klib-macros.h>
#include <klib.h>
#include <stdint.h>

#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

size_t strlen(const char *s) {
  const char *sc;
  for (sc = s; *sc != '\0'; ++sc) {
  }
  return sc - s;
}

char *strcpy(char *dst, const char *src) {
  char *save = dst;
  while ((*dst++ = *src++)) {
  }
  return save;
}

char *strncpy(char *dst, const char *src, size_t n) {
  char *d = dst;
  const char *s = src;
  size_t size = n;
  while (size > 0) {
    size--;
    if ((*d++ = *s++) == '\0') {
      break;
    }
  }
  while (size-- > 0) {
    *d++ = '\0';
  }

  return dst;
}

char *strcat(char *dst, const char *src) {
  char *r = dst;
  while (*dst) dst++;
  while ((*dst++ = *src++)) {
  }
  return r;
}

int strcmp(const char *s1, const char *s2) {
  while (*s1 && (*s1 == *s2)) {
    s1++, s2++;
  }
  return *(const unsigned char *)s1 - *(const unsigned char *)s2;
}

void *memset(void *s, int c, size_t n) {
  unsigned char *p = s;
  while (n--) {
    *p++ = (unsigned char)c;
  }
  return s;
}

void *memmove(void *dst, const void *src, size_t n) {
  char *d = dst;
  const char *s = src;
  if (d < s) {
    while (n--) *d++ = *s++;
  } else {
    const char *lasts = s + (n - 1);
    char *lastd = d + (n - 1);
    while (n--) *lastd-- = *lasts--;
  }
  return dst;
}

void *memcpy(void *out, const void *in, size_t n) {
  char *dst = out;
  const char *src = in;
  while (n--) {
    *dst++ = *src++;
  }
  return out;
}

int memcmp(const void *_s1, const void *_s2, size_t n) {
  const unsigned char *s1 = _s1, *s2 = _s2;
  while (n--) {
    if (*s1 != *s2) {
      return *s1 - *s2;
    }
    s1++, s2++;
  }
  return 0;
}

#endif
