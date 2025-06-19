""" Hyperparameters for Large Scale Data Collection """
import os.path

BASE_DIR = '/'.join(str.split(__file__, '/')[:-1])
current_dir = os.path.dirname(os.path.realpath(__file__))

from multicam_server.topic_utils import IMTopic
from widowx_envs.widowx_env import VR_WidowX
from widowx_envs.control_loops import TimedLoop
from widowx_envs.policies.vr_teleop_policy import VRTeleopPolicy

env_params = {
    'camera_topics': [IMTopic('/blue/image_raw')
                      ],
    # 'depth_camera_topics': [IMTopic('/D435/depth/image_rect_raw', dtype='16UC1')],
    'gripper_attached': 'custom',
    'skip_move_to_neutral': True,
    'move_to_rand_start_freq': -1,
    'fix_zangle': 0.1,
    'move_duration': 0.2,
    'adaptive_wait': True,
    'action_clipping': None
}

agent = {
    'type': TimedLoop,
    'env': (VR_WidowX, env_params),
    'recreate_env': (False, 1),
    'T': 500,
    'image_height': 480,
    'image_width': 640,
    'make_final_gif': False,
    'video_format': 'mp4',
}

policy = {
    'type': VRTeleopPolicy,
}

config = {
    'current_dir' : current_dir,
    'collection_metadata' : current_dir + '/collection_metadata.json',
    'start_index':0,
    'end_index': 500,
    'agent': agent,
    'policy': policy,
    'save_format': ['raw'],
    'make_diagnostics': False,
    'record_floor_height': False
}
