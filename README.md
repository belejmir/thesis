# Content
## frontend
This is a code for the proxy frontend unikernel. It was tested when configured for unix. Listens on port 8080 (can change in unikernel.ml file). It will forward to 192.168.254.11:8081 by default (also changable in unikernel.ml)

## backend 
This is a code for the logic backend. Also tested when configured for unix. Listens on port 8081 (can change in unikernel.ml file). 

## testingFront
This is a code for a version of the frontend which will only return the payload back. Used for testing whether it work inside Muen.

## unified
This is a code for one whole webserver (does the work for both frontend and backend). 
