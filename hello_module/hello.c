// SPDX-License-Identifier: GPL-2.0
/*
 * Hello World Kernel Module for GKI 6.12
 * 
 * A simple kernel module to verify the GKI kernel module compilation process.
 * This module prints messages to kernel log on load and unload.
 */

#include <linux/init.h>
#include <linux/module.h>
#include <linux/kernel.h>

MODULE_LICENSE("GPL");
MODULE_AUTHOR("GKI Kernel Workflow");
MODULE_DESCRIPTION("Hello World Module for GKI 6.12-android16");
MODULE_VERSION("1.0");

static int __init hello_init(void)
{
    pr_info("Hello, GKI 6.12 World!\n");
    pr_info("Module loaded successfully on kernel %s\n", UTS_RELEASE);
    return 0;
}

static void __exit hello_exit(void)
{
    pr_info("Goodbye, GKI 6.12 World!\n");
    pr_info("Module unloaded successfully\n");
}

module_init(hello_init);
module_exit(hello_exit);
