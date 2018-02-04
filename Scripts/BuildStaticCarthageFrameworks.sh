#!/bin/bash

set -e

sh ./Scripts/BuildStaticFramework.sh RxHttpClient RxHttpClient RxHttpClient
sh ./Scripts/BuildStaticFramework.sh RxDataFlow RxDataFlow RxDataFlow-iOS
