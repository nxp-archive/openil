TARGET = icc
SRC = icc-main.c inter-core-comm.c
OBJ = $(patsubst %.c, %.o, $(SRC))

build: $(TARGET)

$(TARGET): $(OBJ)
	$(CC) $^ -o $@ $(LDFLAGS)

%.o: %.c
	$(CC) $(CFLAGS) -c $^ -o $@

clean:
	rm -f $(TARGET) $(OBJ)

.PHONY: build clean uninstall install
