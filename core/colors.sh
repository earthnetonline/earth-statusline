#!/bin/bash
# Earth Status Line - Color Palette
# Muted, subtle, almost grayscale with hints of color
# Using true color (24-bit): \033[38;2;R;G;Bm

C_DIR='\033[38;2;136;136;136m'      # Medium gray #888888
C_BRANCH='\033[38;2;122;130;118m'   # Muted sage-gray #7A8276
C_ADD='\033[38;2;122;130;118m'      # Muted sage-gray #7A8276
C_DEL='\033[38;2;140;130;130m'      # Muted rose-gray #8C8282
C_MODEL='\033[38;2;85;85;85m'       # Dark gray #555555
C_TOKENS='\033[38;2;152;136;184m'   # Soft bluish purple #9888B8
C_CTX_GOOD='\033[38;2;136;168;128m' # Soft sage #88A880
C_CTX_WARN='\033[38;2;168;152;104m' # Soft amber #A89868
C_CTX_BAD='\033[38;2;168;114;104m'  # Soft terracotta #A87268
C_DIM='\033[38;2;102;102;102m'      # Muted gray #666666
C_RESET='\033[0m'
