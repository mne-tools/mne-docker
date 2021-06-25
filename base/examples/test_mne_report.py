# modified from 70_report.py

import os
import os.path as op
import mne
import sys

path = mne.datasets.sample.data_path(verbose=True)

subjects_dir = op.join(path, 'subjects')
report = mne.Report(subject='sample', subjects_dir=subjects_dir,
                    raw_psd=True, projs=True, verbose=True)
report.parse_folder(path, render_bem=True)

fname_stc = op.join(path, 'MEG', 'sample', 'sample_audvis-meg')
stc = mne.read_source_estimate(fname_stc, subject='sample')
figs = list()
kwargs = dict(subjects_dir=subjects_dir, initial_time=0.13,
              clim=dict(kind='value', lims=[3, 6, 9]))
for hemi in ('lh', 'rh'):
    brain = stc.plot(hemi=hemi, **kwargs)
    brain.toggle_interface(False)
    figs.append(brain.screenshot(time_viewer=True))
    brain.close()

# add the stc plot to the report:
report.add_slider_to_section(figs)

if len(sys.argv) >= 2:
    out_fname = sys.argv[1]
else:
    out_fname = op.join(op.dirname(op.realpath(__file__)),
                        'mne_rpt.html')

report.save(out_fname, overwrite=True, open_browser=False)
