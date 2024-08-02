set +xe
mkdir local
cp -r arrowcpp local/
cp -r arrowcpp/include/parquet local/
cp -r arrow/python/pyarrow local/
touch local/__init_.py
touch local/arrowcpp/__init__.py
rm -rf dist/*
python -m pip wheel -w dist -vv .
