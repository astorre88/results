import os
import sys
from struct import unpack, pack
import numpy as np
import cv2
import cvlib as cv
import json
import pickle
import face_recognition

UUID4_SIZE = 16

def setup_io():
    return os.fdopen(3, "rb"), os.fdopen(4, "wb")


def read_message(input_f):
    header = input_f.read(4)
    if len(header) != 4:
        return None

    (total_msg_size,) = unpack("!I", header)

    image_id = input_f.read(UUID4_SIZE)

    image_data = input_f.read(total_msg_size - UUID4_SIZE)

    # converting the binary to a opencv image
    nparr = np.frombuffer(image_data, np.uint8)
    image = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    rgb = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)

    return {'id': image_id, 'image': rgb}


def detect(rgb, model, data):
    print("[INFO] recognizing faces...")
    boxes = face_recognition.face_locations(rgb, model="hog")
    encodings = face_recognition.face_encodings(rgb, boxes)

    names = []

    for encoding in encodings:
        matches = face_recognition.compare_faces(data["encodings"], encoding)
        name = "Unknown"

        if True in matches:
            matchedIdxs = [i for (i, b) in enumerate(matches) if b]
            counts = {}

            for i in matchedIdxs:
                name = data["names"][i]
                counts[name] = counts.get(name, 0) + 1

            name = max(counts, key=counts.get)

        names.append(name)

    return names


def write_result(output, image_id, image_shape, names):
    result = json.dumps({
        'shape': image_shape,
        'names': names
    }).encode("ascii")

    header = pack("!I", len(result) + UUID4_SIZE)
    output.write(header)
    output.write(image_id)
    output.write(result)
    output.flush()


def run(model, encodings):
    input_f, output_f = setup_io()

    print("[INFO] loading encodings...")
    data = pickle.loads(open(encodings, "rb").read())

    while True:
        msg = read_message(input_f)
        if msg is None:
            break

        # image shape
        height, width, _ = msg["image"].shape
        shape = {'width': width, 'height': height}

        # detect object
        names = detect(msg["image"], model, data)

        # send result back to elixir
        write_result(output_f, msg["id"], shape, names)


if __name__ == "__main__":
    model = "yolov3"
    if len(sys.argv) > 1:
        model = sys.argv[1]
        encodings = sys.argv[2]

    run(model, encodings)
