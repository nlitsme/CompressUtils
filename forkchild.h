#ifndef __FORKCHILD_H__
#define __FORKCHILD_H__
#include <signal.h>
class fork_child {
    int _pid;
public:
    fork_child() : _pid(0) { }
    ~fork_child()
    {
#ifndef _WIN32
        kill(_pid, SIGTERM);
#endif
    }
    virtual void initialize_child()
    {
    }
    void run_child(const std::string& svrname, const StringList& args)
    {
#ifndef _WIN32
        _pid= fork();
        if (-1==_pid) 
            throw posixerror("clt:fork");
        if (_pid!=0) {
            ipclog("parent(client), server.pid=%d\n", _pid);
            return;
        }
        ipclog("child(server)\n");

        initialize_child();
        // construct argv

        char**argv= (char**)malloc((args.size()+2)*sizeof(char*));
        argv[0]= (char*)&svrname[0];
        for (unsigned i=0 ; i<args.size() ; i++)
            argv[i+1]= (char*)&args[i][0];
        argv[args.size()+1]= 0;

        execvp(svrname.c_str(), argv);

        fprintf(stderr, "failed to exec %s\n", svrname.c_str());
        throw posixerror("clt:exec");
#else
        PROCESS_INFORMATION procinfo;

        STARTUPINFO startinfo;
        memset(&startinfo, 0, sizeof(STARTUPINFO));
        startinfo.cb= sizeof(STARTUPINFO);

        if (!CreateProcess((char*)svrname.c_str(), (char*)JoinStringList(args, " ").c_str(), 0, 0, 0, 0, 0, 0, &startinfo, &procinfo))
            fprintf(stderr, "error creating process: 0x%x\n", GetLastError());
        else {
            CloseHandle (procinfo.hThread);
            CloseHandle (procinfo.hProcess);
        }
#endif
    }
};
#endif
