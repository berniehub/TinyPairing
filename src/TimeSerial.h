#ifndef TIME_SERIAL_H
#define TIME_SERIAL_H

typedef nx_struct time_serial_msg {
    nx_uint32_t t1;
    nx_uint32_t t2;
    nx_uint32_t t3;
    nx_uint32_t t4;
    nx_uint8_t overflow;
    nx_uint8_t result;
} time_msg;

enum {
    AM_TIME_SERIAL_MSG = 11,
};

#endif /* TIME_SERIAL_H */
