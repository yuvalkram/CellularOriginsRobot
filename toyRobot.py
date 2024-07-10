#!/usr/bin/env python3
import sys
import json


class ToyRobot:
    def __init__(self):
        self.active = False
        self.position = None
        self.direction = None

    def move(self):
        # Move the robot according to the FSM dataset
        if not self.active:
            return
        move = WORLD_DATA["DIRECTIONS"][self.direction]["MOVE"]
        x = self.position[0] + move[0]
        y = self.position[1] + move[1]
        if valid_board_position(x, y):
            self.position = (x, y)

    def left(self):
        # Turn the robot to the left according to the FSM dataset
        if not self.active:
            return
        self.direction = WORLD_DATA["DIRECTIONS"][self.direction]["LEFT"]

    def right(self):
        # Turn the robot to the right according to the FSM dataset
        if not self.active:
            return
        self.direction = WORLD_DATA["DIRECTIONS"][self.direction]["RIGHT"]

    def place(self, x: int, y: int, direction: str):
        # Place the robot on the board if given a valid location and position
        if self.active:
            return
        if not valid_board_position(x, y):
            return
        if direction not in WORLD_DATA["DIRECTIONS"]:
            return
        self.position = (x, y)
        self.active = True
        self.direction = direction

    def report(self):
        # Print the robot's current position and direction
        if not self.active:
            return
        print(self.position[0], self.position[1], self.direction)
    

def valid_board_position(x, y):
    # Check if the robot is within the bounds of the board
    if 0 <= x < WORLD_DATA["GRID"][0] and 0 <= y < WORLD_DATA["GRID"][1]:
        return True
    return False


def parse_place_args(arg):
    # Parse the PLACE command arguments
    x, y, direction = arg.split(",")
    return int(x), int(y), direction


def main(args):
    # Create an instance of ToyRobot
    robot = ToyRobot()

    ROBOT_COMMANDS = {
        "REPORT": robot.report,
        "MOVE": robot.move,
        "LEFT": robot.left,
        "RIGHT": robot.right,
        "PLACE": robot.place
    }

    while args:
        command = args[0]
        args.pop(0)
        if command == "EXIT":
            return;
        if command not in ROBOT_COMMANDS:
            continue
        if (command == "PLACE"):
            try:
                x, y, direction = parse_place_args(args[0])
            except ValueError:
                continue
            ROBOT_COMMANDS[command](x, y, direction)
            args.pop(0)
            continue
        ROBOT_COMMANDS[command]()


if __name__ == "__main__":
    # Information about 'the world' (not the robot) is contained in the data JSON file
    # This is in effect a Finite-State Machine (FSM) mapping the system's state
    with open('data.json') as data:
        WORLD_DATA = json.load(data)
    main(sys.argv[1:])