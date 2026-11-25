# CMP6237 Lab 4: Build a Sample Web App in a Docker Container

## Project overview

This project was completed as part of the CMP6237 Cloud Computing practical labs at Birmingham City University.

The objective was to create a simple Flask web application, package it into a Docker image, run it inside a Docker container, and use Bash scripts to automate deployment and verification.

The project also demonstrates basic Linux scripting, Python virtual environments, Docker image construction, container networking, and container lifecycle management.

## Learning objectives

- Create and execute Bash scripts.
- Build a simple web application using Python and Flask.
- Use HTML templates and CSS to present dynamic web content.
- Define a Docker image using a Dockerfile.
- Build and run Docker containers.
- Publish a container port to the local VM.
- Automate application deployment using Bash.
- Test an HTTP endpoint and inspect a running container.
- Understand the difference between Docker images and containers.

## Technologies and tools

| Technology | Purpose |
|---|---|
| Ubuntu 26.04.1 LTS | Linux development environment |
| Bash | Shell scripting and automation |
| Python 3.14.4 | Host-side Python environment |
| Python 3.14.7 | Python version inside the Docker container |
| Flask 3.1.3 | Python web framework |
| Docker Engine | Containerisation |
| Docker Buildx | Docker build tooling |
| HTML | Web page structure |
| CSS | Web page styling |
| Git | Version control |
| GitHub | Source code hosting |

## Repository structure

```text
cmp6237-lab04/
├── README.md
├── .gitignore
├── Dockerfile
├── requirements.txt
├── app/
│   ├── sample_app.py
│   ├── templates/
│   │   └── index.html
│   └── static/
│       └── style.css
├── scripts/
│   ├── user-input.sh
│   ├── web-app.sh
│   └── test-app.sh
└── docs/
    └── screenshots/
```

## Lab tasks and implementation

### Part 1: Create a simple Bash script

Created a Bash script that accepts a name from the user and displays a personalised message.

The script uses:

- A Bash shebang (`#!/usr/bin/env bash`).
- `read -r` to accept user input.
- `printf` to display the result.
- File permissions to make the script executable.

Example:

```bash
#!/usr/bin/env bash
read -r -p "Enter your name: " userName
printf 'Your name is %s.\n' "$userName"
```

Run the script:

```bash
bash scripts/user-input.sh
```

### Part 2: Create a sample Flask web application

Created a Flask application that listens on port 5000 and responds to requests sent to the root route.

The application binds to `0.0.0.0`, allowing it to listen on all IPv4 interfaces.

### Part 3: Add website files

Extended the Flask application to render an HTML template and serve a CSS stylesheet.

**HTML template:** `app/templates/index.html`

The page displays:
- The heading `CMP6237 Sample App`.
- The client IP address received by the application.
- A reference to the CSS stylesheet.

The template uses Flask's Jinja expression:

```html
{{ request.remote_addr }}
```

**CSS stylesheet:** `app/static/style.css`

The stylesheet provides a light steel blue background, a sans-serif font and page spacing.

### Part 4: Automate the Docker image build and container launch

Created a Dockerfile to package the Flask application and its dependencies into an image.

The Dockerfile uses a pinned Python base-image digest rather than a moving image tag.

Main Dockerfile instructions:

| Instruction | Purpose |
|---|---|
| `FROM` | Selects the base image |
| `WORKDIR` | Sets the working directory inside the container |
| `COPY` | Copies application files into the image |
| `RUN` | Installs Python dependencies |
| `EXPOSE` | Documents the application's container port |
| `CMD` | Defines the command used to start the application |

The direct Flask dependency is recorded in `requirements.txt`:

```text
Flask==3.1.3
```

**Build and deployment automation**

The `scripts/web-app.sh` script:

1. Locates the project root.
2. Builds the Docker image.
3. Checks for an existing container with the lab's name.
4. Removes that previous container if present.
5. Starts a new container.
6. Displays the running container.

Run the deployment script:

```bash
bash scripts/web-app.sh
```

The Docker image is tagged:

```text
cmp6237-lab04:course
```

The container is named:

```text
cmp6237-lab04
```

The port mapping is:

```bash
-p 127.0.0.1:5000:5000
```

This publishes container port 5000 on the VM's loopback address, allowing the application to be accessed from inside the VM at:

```text
http://127.0.0.1:5000/
```

### Part 5: Verify and explore the container

Created `scripts/test-app.sh` to verify that the application responds successfully.

The test:
- Attempts an HTTP request using `curl`.
- Retries while the application starts.
- Checks for the expected application heading.
- Returns a successful or failed test result.

Run the test:

```bash
bash scripts/test-app.sh
```

Expected successful output:

```text
PASS: HTTP response contains the app marker
```

**Inspect the container**

Check the running container:

```bash
docker ps
```

Inspect the Python version:

```bash
docker exec cmp6237-lab04 python --version
```

Inspect installed Python packages:

```bash
docker exec cmp6237-lab04 python -m pip freeze
```

Open a shell inside the container:

```bash
docker exec -it cmp6237-lab04 /bin/sh
```

Explore the working directory:

```bash
pwd
ls
ls templates static
exit
```

**Container lifecycle**

The following commands were used to demonstrate the container lifecycle:

```bash
docker stop cmp6237-lab04
docker ps -a --filter name=^/cmp6237-lab04$

docker start cmp6237-lab04
bash scripts/test-app.sh

docker stop cmp6237-lab04
docker rm cmp6237-lab04

docker image ls cmp6237-lab04
```

The container was stopped, restarted, tested, stopped again and removed. The Docker image remained available after the container was removed.

## Application architecture

```text
Browser / curl
      |
      | HTTP request
      v
127.0.0.1:5000 (VM)
      |
      | Docker published port
      v
Container port 5000
      |
      v
Flask application
      |
      +------> HTML template
      |
      +------> CSS stylesheet
```

## Key technical concepts learned

### Docker image vs container

A Docker image is the packaged application environment used to create containers.

A container is a running or stopped instance created from an image. Removing a container does not automatically remove the image.

### Container port vs published port

`EXPOSE 5000` documents the port the application uses inside the container. It does not make that port accessible on the VM by itself.

The `-p 127.0.0.1:5000:5000` option publishes the container port on the VM's loopback interface.

### Application bind address vs browser URL

The Flask application binds to `0.0.0.0:5000` so it can accept connections through the container's network interfaces.

The browser connects to `127.0.0.1:5000` on the VM because that is the address published by Docker.

### Dockerfile build instructions vs container startup

`RUN` executes commands during image construction. `CMD` defines the default command executed when a container starts.

## Repository improvements

After completing the practical tasks, the project was reorganised to make it easier to maintain and review.

Improvements included:

- Separating application code, templates and static assets.
- Moving Bash scripts into a dedicated `scripts/` directory.
- Using a permanent root-level Dockerfile.
- Updating the deployment script to work with the new directory structure.
- Adding a `.gitignore` file to exclude virtual environments, temporary build files and generated Python files.
- Adding this README to document the implementation and provide repeatable instructions.

## Testing results

| Check | Result |
|---|---|
| Docker image build | Passed |
| Container startup | Passed |
| Port mapping | Confirmed |
| HTTP application response | Passed |
| Application heading check | Passed |
| Container Python version inspection | Completed |
| Python package inspection | Completed |
| Container shell inspection | Completed |
| Container stop and restart | Completed |
| Container removal | Completed |
| Image retention after container removal | Confirmed |

## Limitations and possible future improvements

This is a small academic demonstration, not a production deployment.

Possible improvements include:

- Add automated Python unit tests.
- Use a production-grade WSGI server instead of Flask's development server.
- Add Docker health checks.
- Introduce a non-root container user.
- Add a CI workflow to run tests automatically when changes are pushed.
- Improve logging and application error handling.

## References

- [Dockerfile reference](https://docs.docker.com/reference/dockerfile/)
- [Flask documentation](https://flask.palletsprojects.com/en/stable/quickstart/)

---

**Project:** CMP6237 Lab 4  
**Topic:** Building and running a Flask web application in Docker  
**Environment:** Ubuntu Linux, Python, Flask and Docker
