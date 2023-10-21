CXX			 = clang++

CXXFLAGS ?= -fsanitize=address -Wall -Wextra -g
CXXFLAGS += -std=c++20

CXXFLAGS += `pkg-config --cflags opencv`
LDFLAGS  += `pkg-config --libs opencv`

TARGET ?= peony 
SRC    = main.cpp

all: $(TARGET)
clean:
	rm -f $(TARGET)

$(TARGET): $(SRC)
	$(CXX) -o $@ $^ $(CXXFLAGS) $(LDFLAGS)

.PHONY: all clean
