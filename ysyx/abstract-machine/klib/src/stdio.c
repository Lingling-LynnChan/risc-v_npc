#include <am.h>
#include <klib-macros.h>
#include <klib.h>
#include <limits.h>
#include <stdarg.h>
#if !defined(__ISA_NATIVE__) || defined(__NATIVE_USE_KLIB__)

static void itoa(char *buf, unsigned int val, int base, bool is_signed) {
  char *p = buf;
  if (is_signed && (int)val < 0) {
    *p++ = '-';
    val = -val;
  }
  char *start = p;
  do {
    unsigned int digit = val % base;
    *p++ = (digit < 10) ? ('0' + digit) : ('a' + digit - 10);
    val /= base;
  } while (val);
  *p-- = '\0';
  while (start < p) {
    char tmp = *start;
    *start++ = *p;
    *p-- = tmp;
  }
}
static int safe_strncpy(char *dest, const char *src, int n) {
  int i;
  for (i = 0; i < n - 1 && src[i] != '\0'; i++) {
    dest[i] = src[i];
  }
  if (n > 0) {
    dest[i] = '\0';
  }
  return i;
}

int printf(const char *fmt, ...) {
  char buf[2048];
  va_list ap;
  va_start(ap, fmt);
  int printed_length = vsnprintf(buf, sizeof(buf), fmt, ap);
  va_end(ap);
  for (int i = 0; buf[i] != '\0'; i++) {
    putch(buf[i]);
  }
  return printed_length;
}

int vsprintf(char *out, const char *fmt, va_list ap) {
  char *p, *sval;
  int ival;
  unsigned uval;
  for (p = out; *fmt; fmt++) {
    if (*fmt != '%') {
      *p++ = *fmt;
      continue;
    }
    fmt++;
    switch (*fmt) {
      case 'd':
        ival = va_arg(ap, int);
        sprintf(p, "%d", ival);
        while (*p) p++;
        break;
      case 'x':
        uval = va_arg(ap, unsigned);
        sprintf(p, "%x", uval);
        while (*p) p++;
        break;
      case 's':
        for (sval = va_arg(ap, char *); *sval; sval++) *p++ = *sval;
        break;
      default:
        *p++ = *fmt;
        break;
    }
  }
  *p = '\0';
  return p - out;
}

int sprintf(char *out, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int result = vsnprintf(out, 0x7fffffff, fmt, ap);
  va_end(ap);
  return result;
}

int snprintf(char *out, size_t n, const char *fmt, ...) {
  va_list ap;
  va_start(ap, fmt);
  int result = vsnprintf(out, n, fmt, ap);
  va_end(ap);
  return result;
}

int vsnprintf(char *out, size_t n, const char *fmt, va_list ap) {
  char *p = out;
  char *end = out + n - 1;
  for (; *fmt && p < end; fmt++) {
    if (*fmt != '%') {
      *p++ = *fmt;
      continue;
    }
    fmt++;
    switch (*fmt) {
      case 'd': {
        int ival = va_arg(ap, int);
        char buf[20];
        itoa(buf, ival, 10, true);
        p += safe_strncpy(p, buf, end - p + 1);
        break;
      }
      case 'x': {
        unsigned uval = va_arg(ap, unsigned);
        char buf[20];
        itoa(buf, uval, 16, false);
        p += safe_strncpy(p, buf, end - p + 1);
        break;
      }
      case 's': {
        char *sval = va_arg(ap, char *);
        p += safe_strncpy(p, sval, end - p + 1);
        break;
      }
      default:
        if (p < end) {
          *p++ = *fmt;
        }
        break;
    }
  }
  if (p <= end) {
    *p = '\0';
  } else if (n > 0) {
    *end = '\0';
  }
  return p - out;
}

#endif
