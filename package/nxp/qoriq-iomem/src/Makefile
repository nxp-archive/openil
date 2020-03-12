prefix ?= /usr
exec_prefix ?= ${prefix}
sbindir ?= ${exec_prefix}/sbin

override CFLAGS += -Wextra -Wall -Wunused-function -Wunused-label
override LDFLAGS += -lreadline

TARGET = iomem
SRC = iomem.c
OBJ = $(patsubst %.c, %.o, $(SRC))

build: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

install: $(TARGET)
	install -m 0755 -D $(TARGET) $(DESTDIR)${sbindir}/$(TARGET)

uninstall:
	rm -rf $(DESTDIR)${sbindir}/$(TARGET)

clean:
	rm -f $(TARGET) $(OBJ)

.PHONY: build clean uninstall install
