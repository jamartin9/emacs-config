""" Game fix for Fallout: New Vegas
"""
# pylint: disable=C0103
from protonfixes import util
from protonfixes.protonversion import DeprecatedSince

@DeprecatedSince("5.0-3")
def main():
    """ Use D3D9, quartz for audio, disable AA & water reflections/refractions
    """
    # DX9 game
    util.disable_dxvk()

    # quartz for audio
    util.protontricks('quartz')

    # Graphics and HUD glitches when
    # AntiAliasing and Water Reflections/Refractions are enabled
    # https://github.com/ValveSoftware/Proton/issues/356
    user_opts = '''
    [Display]
    iMultiSample=0

    [Water]
    bUseWaterReflections=0
    bUseWaterRefractions=0
    '''
    util.set_ini_options(user_opts, 'My Games/FalloutNV/FalloutPrefs.ini')
