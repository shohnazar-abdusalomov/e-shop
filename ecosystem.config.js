{
  "apps": [
    {
      "name": "eshop-app",
      "script": "npm",
      "args": "run preview",
      "cwd": "/var/www/eshop/client",
      "instances": 1,
      "exec_mode": "cluster",
      "env": {
        "NODE_ENV": "production",
        "PORT": 3000
      },
      "error_file": "/var/log/pm2/eshop-error.log",
      "out_file": "/var/log/pm2/eshop-out.log",
      "log_date_format": "YYYY-MM-DD HH:mm:ss Z",
      "max_restarts": 10,
      "min_uptime": 10000,
      "max_memory_restart": "1G"
    }
  ]
}
