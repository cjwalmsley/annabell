/*
 * EmptyCommand.cpp
 *
 *  Created on: Jan 11, 2016
 *      Author: jpp
 */

#include <Annabell.h>
#include <AnnabellFlags.h>
#include <display.h>
#include <EmptyCommand.h>
#include <fssm.h>
#include <gettime.h>
#include <Monitor.h>
#include <sizes.h>
#include <ssm.h>
#include <stdint.h>
#include <cstdio>
#include <ctime>
#include <iostream>
#include <string>
#include <vector>

int GetInputPhrase(Annabell *annabell, Monitor *Mon, string input_phrase);
int ExecuteAct(Annabell *annabell, Monitor *Mon, int rwd_act, int acq_act, int el_act);
string Exploitation(Annabell *annabell, Monitor *Mon, display* Display, int n_iter);

using namespace sizes;

static const uint32_t kLinksFileMagic = 0x414E4C4B; // ANLK
static const uint32_t kLinksFileVersion = 1;

template <typename T>
static bool WriteValue(FILE *fp, const T &value)
{
	return fwrite(&value, sizeof(T), 1, fp)==1;
}

static bool WriteLinksHeader(FILE *fp)
{
	if (!WriteValue(fp, kLinksFileMagic)) return false;
	if (!WriteValue(fp, kLinksFileVersion)) return false;
	if (!WriteValue(fp, WMSize)) return false;
	if (!WriteValue(fp, NC)) return false;
	if (!WriteValue(fp, PhSize)) return false;

	return true;
}

EmptyCommand::EmptyCommand() :
		Command() {
}

int EmptyCommand::execute() {
	string target_phrase;
	Display->Print("\n");
	target_phrase = ".end_context";
	GetInputPhrase(annabell, Mon, target_phrase);
	ExecuteAct(annabell, Mon, NULL_ACT, MEM_PH, NULL_ACT);
	Display->Print(" >>> End context\n");
	annabell->flags->StartContextFlag = true;

	// answer time
	if (annabell->flags->AnswerTimeFlag && annabell->flags->AnswerTimeUpdate
			&& annabell->flags->AnswerTimePhrase != "") {
		struct timespec clk0, clk1;
		GetRealTime(&clk0);

		annabell->flags->AnswerTimeUpdate = false;
		ExecuteAct(annabell, Mon, STORE_ST_A, NULL_ACT, FLUSH_OUT);
		GetInputPhrase(annabell, Mon, annabell->flags->AnswerTimePhrase);
		Exploitation(annabell, Mon, Display, 1);

		GetRealTime(&clk1);
		double answ_time = clk1.tv_sec - clk0.tv_sec + (double) (clk1.tv_nsec - clk0.tv_nsec) * 1e-9;
		double link_num = (double) annabell->ElActfSt->CountSparseInputLinks();
		FILE *at_fp = fopen("answer_time.dat", "a");
		fprintf(at_fp, "%.3e\t%.3f\n", link_num, answ_time);
		fclose(at_fp);
	}
	// auto save links
	if (annabell->flags->AutoSaveLinkFlag) {
		double link_num = (double) annabell->ElActfSt->CountSparseInputLinks();
		int index = (int) (link_num / annabell->flags->AutoSaveLinkStep);
		if (index > annabell->flags->AutoSaveLinkIndex) {
			annabell->flags->AutoSaveLinkIndex = index;
			char filename[20];
			sprintf(filename, "links_%d.dat", annabell->flags->AutoSaveLinkIndex);
			FILE *fp = fopen(filename, "wb");
			if (fp == NULL) {
				Display->Warning("cannot open links file for writing.");
				return 1;
			}
			if (!WriteLinksHeader(fp)) {
				Display->Warning("Error writing links file header.");
				fclose(fp);
				return 1;
			}
			Mon->SaveWM(fp);
			if (annabell->MemPh->HighVect.size() != 1) {
				Display->Warning("Error on MemPh.");
				fclose(fp);
				return 1;
			}
			if (fwrite(&annabell->MemPh->HighVect[0], sizeof(int), 1, fp) != 1) {
				Display->Warning("Error writing MemPh.");
				fclose(fp);
				return 1;
			}
			if (annabell->StartPh->HighVect.size() != 1) {
				Display->Warning("Error on StartPh.");
				fclose(fp);
				return 1;
			}
			if (fwrite(&annabell->StartPh->HighVect[0], sizeof(int), 1, fp) != 1) {
				Display->Warning("Error writing StartPh.");
				fclose(fp);
				return 1;
			}

			annabell->IW->SaveNr(fp);
			annabell->IW->SaveInputLinks(fp);
			annabell->ElActfSt->SaveNr(fp);
			annabell->ElActfSt->SaveSparseInputLinks(fp);
			annabell->ElActfSt->SaveOutputLinks(fp);
			annabell->RemPh->SaveSparseOutputLinks(fp);
			annabell->RemPhfWG->SaveNr(fp);
			annabell->RemPhfWG->SaveSparseInputLinks(fp);
			annabell->RemPhfWG->SaveSparseOutputLinks(fp);

			fclose(fp);
		}
	}
	// added 5/01/2013
	annabell->SetAct(START_ST_A, NULL_ACT, NULL_ACT);
	annabell->StActRwdUpdate();
	Mon->Print();
	annabell->Update();
	ExecuteAct(annabell, Mon, STORE_ST_A, NULL_ACT, NULL_ACT);

	return 0;
}

