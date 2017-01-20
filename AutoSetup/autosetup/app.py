#!/usr/bin/env  python
#-*- coding: utf-8 -*-

"""
使用setupfacory进行打包时，不同的环境需要不同的配置，打包时需要手动点击太麻烦了。
所以开发了基于命令行的自动化打包工具，一条命令自动完成打包工作。
"""

__author__ = 'liu rui'

from argparse import ArgumentParser


def main():
    parser = ArgumentParser(description=__doc__)

if __name__ == '__main__':
    main()
