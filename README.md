Build the image:

```console
% PROJECT=$(basename `pwd`)
% docker image build -t $PROJECT-image . --build-arg user_id=`id -u` --build-arg group_id=`id -g`
```

Run docker containers:

```console
% docker container run -it --rm --init -p 6080:80 --shm-size=512m --name $PROJECT-container $PROJECT-image /bin/start-vnc.sh
```

The websockify can be accessed at:

- http://localhost:6080/vnc.html

See also:
- https://kamino.hatenablog.com/entry/docker_vnc
- https://medium.com/@gustav0.lewin/how-to-make-a-docker-container-with-vnc-access-f607958141ae

