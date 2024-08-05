Build the image:

```console
% PROJECT=$(basename `pwd`)
% docker image build -t $PROJECT-image . --build-arg user_id=`id -u` --build-arg group_id=`id -g`
```

Run docker containers:

```console
% docker container run -it --rm --init -p 6080:80 --shm-size=512m --name $PROJECT-container $PROJECT-image /bin/zsh
```

Run the following commands inside the Docker containers:

```console
% USER=root vncserver :1 -geometry 800x600 -depth 24
% websockify -D --web=/usr/share/novnc/ 80 localhost:5901
```

The websockify can be accessed at:

- http://localhost:6080/vnc.html

See also:
https://kamino.hatenablog.com/entry/docker_vnc
