prefix ?= /usr
exec_prefix ?= ${prefix}
bindir ?= ${exec_prefix}/bin

override CFLAGS += -std=c99 -Wextra -Wall -Wunused-function -Wunused-label
override LDFLAGS += -lsja1105 -lopen62541

TARGET = opc-sja1105
SRC = opc-sja1105.c
OBJ = $(patsubst %.c, %.o, $(SRC))

build: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

install: $(TARGET)
	install -m 0755 -D $(TARGET) $(DESTDIR)${bindir}/$(TARGET)

uninstall:
	rm -rf $(DESTDIR)${bindir}/$(TARGET)

clean:
	rm -f $(TARGET) $(OBJ)

.PHONY: build clean uninstall install
