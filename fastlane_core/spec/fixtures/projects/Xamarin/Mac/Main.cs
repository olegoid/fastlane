﻿using AppKit;

namespace Mac
{
	static class MainClass
	{
		static void Main(string[] args)
		{
			NSApplication.Init();
			NSApplication.Main(args);
		}
	}
}
