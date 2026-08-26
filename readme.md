# MMAR Metamodeling Platform - Docker Installation

Welcome to the **MMAR Docker Installation** repository! This guide will walk you through installing and managing the MMAR platform using Docker. Installing MMAR with Docker simplifies setup, minimizes potential issues, and provides an efficient environment for both development and production.

## Installation

### Prerequisites

Ensure that you have the following software installed on your machine:

- [Docker](https://docs.docker.com/get-docker/)

Clone the repository to your local machine and navigate to the directory:

<!-- https://github.com/MM-AR/mmar-docker-installation.git --> 
```bash
git clone https://github.com/MM-AR/mmar-docker-installation.git
cd mmar-docker-installation
```

Make sure that docker is running. You can check this by running the following command or just open the Docker Desktop application:

```bash
docker info
```

You can install and start the MMAR environment using a single command depending on your desired mode:

---
### Quick Start Production Mode

Before starting the production mode, make sure that you adapt the `.env` file to your needs. You can find the file in the `root` directory.
If you want to run the production mode on a local machine and expose it to localhost, check the environment variables `API_URL` and `ALLOWED_HOSTS` to `localhost` (in the files `.env-mmar-metamodeling-client-react-prod` and `.env-mmar-modeling-client-react-prod`). The `API_URL` should be set to `http` and not `https`. (By default no changes needed).

If you want to run the production mode on a production server, set the environment variable `API_URL` and `ALLOWED_HOSTS` to the domain name of your server and use `https` for the `API_URL`. 

To start the production mode, run:

```bash
docker compose --env-file .env up
```

To stop the production mode, run:

```bash
docker compose --env-file .env down
```

To completely remove all containers, images, and volumes associated with MMAR, use:

```bash
docker compose down --rmi all --volumes
```
---

### Quick Start Development Mode

If you want to develop something for the MMAR platform, you can use the development mode. This mode is not recommended for production use. This mode is exposed to localhost. You can access it by using the VS Code Remote Development extension.

The development mode uses the `.env-dev` file for configuration. You can find the file in the `root` directory. You can change the environment variables in this file to suit your needs.

If you want to run the development mode on a local machine and expose it to localhost (default scenario), set the environment variables `API_URL` and `ALLOWED_HOSTS` to `localhost` (in the files `.env-mmar-metamodeling-client-react-development` and `.env-mmar-modeling-client-react-development`). The `API_URL` should be set to `http` and not `https` (by default no changes needed).

To start the development mode, run:
```bash
docker compose --env-file .env-dev up
```

This will set up and start the necessary containers for MMAR. The first time you run this command, it may take a while to download the required images and set up the containers. Subsequent runs will be faster as Docker caches the images. 

Check the console output for any errors. If everything is set up correctly, you can access the API Server at [http://localhost:8000/login](http://localhost:8000/login), the Metamodeling Client at [http://localhost:8075](http://localhost:8075), and the Modeling Client at [http://localhost:8085](http://localhost:8085). 

By using the VS Code Remote Development extension (See section `Attach Container to VSCode`), you can access the code base in an IDE to make changes. 

Note that the development server does start the node projects of the API server, the modeling client, and the metamodeling client by default at start up. Check the console outputs of the containers to see if everything is running correctly. You can also check the output during development.

To stop the development mode, run:

```bash
docker compose --env-file .env-dev down
```

To completely remove all containers, images, and volumes associated with MMAR, use:

```bash
docker compose down --rmi all --volumes
```

---


## Attach Container to VSCode
If you are in development mode, open VSCode and open a remote connection in your VSCode Desktop installation.

To attach a running container in VSCode, follow these instructions: https://code.visualstudio.com/docs/devcontainers/attach-container
```It should be sufficient to just attach the running Docker container. You do not have to configure additional settings.```

The repositories are located in the shared volume ```/usr/src/app/shared/mmar``` directory. You can either attach just one container and open the mmar directory to see all the repository projects, or you can attach all the containers and open the mmar directory in each container separately.

Be aware that most users are not allowed to push directly to the main and develop branches. By default, the development container fetches the development branch. If you want to develop your own features, create a fork of the repository you are working on. When finished, create a ```pull request``` to the develop branch.

## Configuration

The MMAR platform can be configured using environment variables. These variables are defined in the `.env` files located in the `root` directory. You can modify these files to suit your needs. `.env-dev` and `.env` are for the configuration of the Docker variables. All the `.env-mmar...` files, located in the `conf` forlder of each container folder, are passed on to the different project folders. Only change something if you know what you are doing. By default, you can just let the files as they are. (see section `Environment Variables` for more details).

> **<span style="color:gold">Hint:</span> If your machine has ample resources (i.e. >= 16GB), you can remove all memory and CPU limits in the `docker-compose.yml` file to speed up the build process for all containers.**

## Environment Variables

The MMAR platform is configured using environment variables defined in the `.env` and `.env-dev` files in the root directory, as well as `.env-mmar-*` files in each service's `conf` folder. Below is a comprehensive list of all relevant variables, their purpose, and where they are used.

### PostgreSQL Configuration

- `POSTGRES_USER`: Username for the PostgreSQL database (default: `api`)
- `POSTGRES_PASSWORD`: Password for the PostgreSQL database (default: `root`)
- `POSTGRES_DB`: Name of the PostgreSQL database (default: `api`)
- `POSTGRES_HOST`: Hostname for the PostgreSQL database (should be `database` for Docker Compose networking)

### General Configuration

- `GIT_BRANCH`: The branch of the Git repository to use (e.g., `main`, `develop`)
- `PRODUCTION`: Set to `true` for production mode, `false` for development mode
- `DELETE_NODE_MODULES`: Also used in scripts for node_modules cleanup (set to `true` or `false`)

### API Server Configuration

The API server reads a single `.env` file. `npm-installation-server.sh` picks
which one to copy from the `PRODUCTION` variable of the root env file:
`.env-mmar-api-prod` when `PRODUCTION=true`, `.env-mmar-api-development`
otherwise. Both live in `mmar-server/conf`.

The server validates this configuration while it starts and refuses to boot on a
bad one, rather than failing later on a request.

- `API_SERVER_PORT`: The port on which the API server will run, published by `docker-compose.yml` (default: `8000`)
- `HTTPPORT`: The port the Node.js API server listens on. Must match `API_SERVER_PORT` (default: `8000`)
- `JWT_SECRET`: **Mandatory.** Secret key used to sign and verify the JSON web tokens. At least 32 characters, or the server will not start. Generate one with `openssl rand -base64 48`. `mmar-sync-server` verifies those tokens locally, so its `JWT_SECRET` must be byte-identical
- `PGPASSWORD`: **Mandatory.** Password of the database role the server connects as. Must match `POSTGRES_PASSWORD` in the root env file
- `PGHOST`, `PGPORT`, `PGUSER`, `PGDATABASE`: Database connection details (defaults: `database`, `5432`, `api`, `api`)
- `PGPOOL_MAX`: Connections held open by the server. Must stay well below the database's own `max_connections` across all instances (default: `25`)
- `PGPOOL_IDLE_TIMEOUT_MS`, `PGPOOL_CONNECT_TIMEOUT_MS`: Pool timeouts in ms (defaults: `30000`, `10000`)
- `PG_STATEMENT_TIMEOUT_MS`, `PG_QUERY_TIMEOUT_MS`: Upper bound on a single query in ms, so a runaway statement cannot pin a connection (defaults: `30000`)
- `NODE_ENV`: `development` enables verbose logging. Anything else, including unset, is treated as a production deployment
- `CORS_ORIGINS`: Comma-separated browser origins allowed to call the API. The API accepts cookie authentication, so this cannot be left open to every origin: left empty, any origin may call the API but credentials are refused. Both files ship with every client port published by `docker-compose.yml`
- `PUBLIC_BASE_URL`: Base url used to build the links returned for uploaded files. Falls back to the host of the incoming request when unset. Set it when the server sits behind a reverse proxy
- `TOKEN_EXPIRE_TIME`: Lifetime of an issued token, in the notation accepted by jsonwebtoken (`30m`, `8h`, `7d`) or a plain number of seconds. There is no revocation list, so this is also how long a leaked token stays usable (default: `8h`)
- `SECURITY_AUDIT_PERSIST_TOKEN_SUCCESS`: Record successful token verifications in `logging.t_security_event`. That is one insert per authenticated API call, so it is off by default. Sign ins, rejections and privilege changes are always recorded (default: `false`)

### Sync Server Configuration

The sync server follows the same pattern: `npm-installation-sync-server.sh`
copies `.env-mmar-sync-server-prod` when `PRODUCTION=true` and
`.env-mmar-sync-server-development` otherwise, both from
`mmar-sync-server/conf`.

- `PORT`: The port the websocket server listens on. Must match the port published for `mmar-sync-server` in `docker-compose.yml` (default: `8060`)
- `JWT_SECRET`: The sync server verifies the tokens issued by `mmar-server` locally instead of calling back for every message, so this **must be byte-identical** to `JWT_SECRET` in the matching `mmar-server` env file. A mismatch shows up as clients being disconnected with code `4401` (`bad-jwt`)
- `API_URL`: The API the sync server asks for a caller's access level on a scene instance. This is the docker-compose service name, not `localhost`, because the request travels over the compose network (default: `http://mmar-server:8000`)

### Client Configuration (Modeling and Metamodeling Client)

- `API_URL`: URL of the API endpoint (e.g., `http://localhost:8000` for local, or your domain for production)
- `HTTPS`: Set to `true` to enable HTTPS, `false` otherwise
- `ANALYZE`: Set to `true` to enable bundle analysis, `false` otherwise
- `PORT`: The port on which the client will run (e.g., `8085` for modeling, `8075` for metamodeling)
- `COMPRESS`: Set to `true` to enable compression, `false` otherwise
- `ALLOWED_HOSTS`: Comma-separated list of allowed hosts (e.g., `localhost` or your domain)
- `ERRORS`, `WARNINGS`, `RUNTIME_ERRORS`: Set to `true` to enable overlays for errors, warnings, and runtime errors respectively
- `HOT`, `LIVE_RELOAD`: Set to `true` to enable hot reload and live reload respectively
- `USERNAME`, `PASSWORD`: Default user credentials for the client (default: `admin`/`admin`)
- `CI`: Set to `true` to open the Bero user interface after the server starts

### Performance and Resource Limits

Set these in your `.env` or `.env-dev` to control Docker resource allocation for each container. These variables are referenced in docker-compose.yml and determine the memory and CPU limits for each service.

- `DB_SERVER_MEMORY_LIMIT`: Memory limit for the database container (e.g., `2G`)
- `DB_SERVER_CPU_LIMIT`: CPU limit for the database container (e.g., `2`)
- `API_SERVER_MEMORY_LIMIT`: Memory limit for the API server container (e.g., `2G`)
- `API_SERVER_CPU_LIMIT`: CPU limit for the API server container (e.g., `2`)
- `SYNC_SERVER_MEMORY_LIMIT`: Memory limit for the sync server container (e.g., `1G`)
- `SYNC_SERVER_CPU_LIMIT`: CPU limit for the sync server container (e.g., `1`)
- `METAMODELING_REACT_CLIENT_MEMORY_LIMIT`: Memory limit for the metamodeling client container (e.g., `6G`)
- `METAMODELING_REACT_CLIENT_CPU_LIMIT`: CPU limit for the metamodeling client container (e.g., `2`)
- `MODELING_REACT_CLIENT_MEMORY_LIMIT`: Memory limit for the modeling client container (e.g., `6G`)
- `MODELING_REACT_CLIENT_CPU_LIMIT`: CPU limit for the modeling client container (e.g., `2`)

How it works:

These variables are used in the mem_limit and cpus fields of each service in `docker-compose.yml`.
If a variable is not set, a default value is used (e.g., 2G for memory, 2 for CPU).
You can adjust these values in .env (for production) or .env-dev (for development) to fit your system’s resources. 


### Notes

- The `.env` file is used for production, `.env-dev` for development.
- Each client and server service has its own `.env-mmar-*` files in its `conf` folder for additional configuration, one `-development` and one `-prod` per service. Which of the two is used follows the `PRODUCTION` variable of the root env file, so you never have to switch them by hand.
- For local development, set `API_URL` and `ALLOWED_HOSTS` to `localhost` in the relevant `.env-mmar-*` files.
- For production, set `API_URL` and `ALLOWED_HOSTS` to your domain and use `https` for `API_URL`.
- The `JWT_SECRET` shipped in the `-prod` files of `mmar-server` and `mmar-sync-server` is committed to this public repository and has to be considered known to everyone. Replace it in **both** files with your own `openssl rand -base64 48` before exposing a deployment to anyone else.
- The `initiator` container clones every repository and installs `mmar-global-data-structure` (gds), which the server, the sync server and both clients build against. When it is done it creates the marker file `/usr/src/app/shared/mmar/.gds-install-complete` in the shared volume; the other containers wait for that marker before they install and build. Because of this, the `initiator` has to run: starting a single service (e.g. `docker compose up mmar-server`) will wait forever unless `initiator` is started as well.

**Always restart your containers after changing environment variables.**

## Sequence Diagram 
The following sequence diagram illustrates the set up of the Docker project. Other sequence diagrams can be found in the `images` folder. 

![alt text](images/mmar-docker-installation-sequence-diagram.svg "MMAR Docker Installation Sequence Diagram")

## Contributing

We welcome contributions! Feel free to fork the repository, create feature branches, and submit pull requests.

## License

This repository is licensed under the GNU AFFERO GENERAL PUBLIC LICENSE Version 3.

## Authors
- [Fabian Muff](https://www.unifr.ch/inf/digits/en/group/team/fabian-muff.html) - [GitHub](https://github.com/fabian-muff)

