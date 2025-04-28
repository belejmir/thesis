# Content

All the unikernels were built with -l \\*:debug.

## mySetup
Contains my version of system policy and coresponding scheduling plan for the policy.

## frontend
This is a code for the proxy frontend unikernel. It was tested when configured for unix. Listens on port 8080 (can change in unikernel.ml file). It will forward to 192.168.254.11:8081 by default (also changable in unikernel.ml). Built unikernel configured for 192.168.254.10/24.

## backend 
This is a code for the logic backend. Also tested when configured for unix. Listens on port 8081 (can change in unikernel.ml file). Built unikernel configured for 192.168.254.11/24.

## testingFront
This is a code for a version of the frontend which will only return the payload back. Used for testing whether it work inside Muen. Built unikernel configured for 192.168.254.10/24.

## unified
This is a code for one whole webserver (does the work for both frontend and backend). Built unikernel configured for 192.168.254.10/24.
