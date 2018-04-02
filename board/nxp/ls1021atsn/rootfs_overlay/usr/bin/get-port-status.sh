#!/bin/bash

##############################################################################
# Copyright 2016-2018 NXP
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
# 1. Redistributions of source code must retain the above copyright notice,
# this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright notice,
# this list of conditions and the following disclaimer in the documentation
# and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from this
# software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
##############################################################################

status=`sja1105-tool status port 0`
host1_sent=`echo "$status" | awk '/N_TXFRM/  {print $2}'`
host1_recv=`echo "$status" | awk '/N_RXFRM/  {print $2}'`
host1_drop=`echo "$status" | awk '/N_POLERR/ {print $2}'`
status=`sja1105-tool status port 2`
host2_sent=`echo "$status" | awk '/N_TXFRM/  {print $2}'`
host2_recv=`echo "$status" | awk '/N_RXFRM/  {print $2}'`
host2_drop=`echo "$status" | awk '/N_POLERR/ {print $2}'`
status=`sja1105-tool status port 4`
host3_sent=`echo "$status" | awk '/N_TXFRM/  {print $2}'`
host3_recv=`echo "$status" | awk '/N_RXFRM/  {print $2}'`
host3_drop=`echo "$status" | awk '/N_POLERR/ {print $2}'`

echo "sent-frames: host1 $host1_sent host2 $host2_sent host3 $host3_sent"
echo "recv-frames: host1 $host1_recv host2 $host2_recv host3 $host3_recv"
echo "drop-frames: host1 $host1_drop host2 $host2_drop host3 $host3_drop"
