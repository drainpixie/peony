CXX			 = clang++

CXXFLAGS ?= -fsanitize=address -Wall -Wextra -g
CXXFLAGS += -std=c++23
# CXXFLAGS += `pkg-config --cflags ncurses`

# LDFLAGS  += `pkg-config --libs ncurses`

TARGET = peony 
SRC    = main.cpp

all: $(TARGET)
clean:
	rm -f $(TARGET)

$(TARGET): $(SRC)
	$(CXX) -o $@ $^ $(CXXFLAGS) # $(LDFLAGS)

.PHONY: all clean
